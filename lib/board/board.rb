require 'pry-byebug'
require 'require_all'
require_rel '../pieces'
require_rel 'square'

class Board
  attr_accessor :positions, :piece_list, :moves_list

  SIZE = 8
  COLORS = %i[white black].freeze

  LIGHT_SQUARE = :on_light_yellow
  DARK_SQUARE = :on_yellow
  CAPTURE_SQUARE = :on_red
  SELECT_SQUARE = { white: :on_blue, black: :on_green }.freeze
  MOVE_MARKER = { white: "\u25CF".blue, black: "\u25CF".green }.freeze

  PIECE_TYPES = [Queen, Rook, Bishop, Knight, Pawn, King].freeze
  FIRST_RANK = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].freeze
  SECOND_RANK = Array.new(SIZE, Pawn).freeze

  def initialize
    @positions = Array.new(SIZE) { Array.new(SIZE) }
    @piece_list = { COLORS[0] => [], COLORS[1] => [] }
    @moves_list = []
    setup
  end

  def setup
    populate_grid
    populate_pieces
    sort_piece_lists
    add_sentinels
  end

  def populate_grid
    @positions.each_with_index do |row, i|
      row.each_with_index do |_square, j|
        if i.even?
          @positions[i][j] =
            j.even? ? Square.new(LIGHT_SQUARE) : Square.new(DARK_SQUARE)
        else
          @positions[i][j] =
            j.odd? ? Square.new(LIGHT_SQUARE) : Square.new(DARK_SQUARE)
        end
      end
    end
  end

  def populate_pieces
    row_offset = 0
    col_offset = -1

    [FIRST_RANK, SECOND_RANK].each do |rank|
      rank.each_with_index do |piece, index|
        black_piece = piece.new(COLORS[1])
        white_piece = piece.new(COLORS[0])

        @positions[row_offset][index].occupant = black_piece
        @positions[col_offset][index].occupant = white_piece

        @piece_list[COLORS[1]] << {
          piece: black_piece,
          position: [2 + row_offset, 2 + index]
        }
        @piece_list[COLORS[0]] << {
          piece: white_piece,
          position: [10 + col_offset, 2 + index]
        }
      end
      row_offset += 1
      col_offset -= 1
    end
  end

  def sort_piece_lists
    @piece_list.each_value do |list|
      list.sort! { |a, b| b[:piece].value <=> a[:piece].value }
    end
  end

  def add_sentinels
    @positions.each do |row|
      2.times { row.unshift(nil) }
      2.times { row.push(nil) }
    end
    2.times { @positions.unshift(Array.new(SIZE + 4)) }
    2.times { @positions.push(Array.new(SIZE + 4)) }
  end

  def display(selected_coords = nil, moves_list = nil)
    if selected_coords.nil? || moves_list.nil?
      grid = @positions
    else
      positions_serialized = Marshal.dump(@positions)
      grid = Marshal.load(positions_serialized)
      add_overlay(grid, selected_coords, moves_list)
    end

    to_string(grid)
  end

  def add_overlay(grid, selected_coords, moves_list)
    color = grid[selected_coords[0]][selected_coords[1]].occupant.color
    grid[selected_coords[0]][selected_coords[1]].background_color =
      SELECT_SQUARE[color]

    moves_list.each do |move|
      if grid[move[0]][move[1]].empty?
        grid[move[0]][move[1]].occupant = MOVE_MARKER[color]
      else
        grid[move[0]][move[1]].background_color = CAPTURE_SQUARE
      end
    end
  end

  def to_string(grid)
    output = ''
    grid.each_with_index do |row, i|
      next if row[2].nil?

      output << "\t#{SIZE + 2 - i} "
      row.each { |square| output << square.to_string unless square.nil? }
      output << "\n"
    end
    output << "\t  "
    ('a'..'h').each { |letter| output << " #{letter} " }

    puts output
  end

  def valid_input?(string)
    return false unless string.length == 2

    string.match?(/[a-h][1-8]/i)
  end

  def position_to_array(string)
    row = 10 - string[1].to_i
    col = (string[0].upcase.ord - 65) + 2
    [row, col]
  end

  def array_to_position(array)
    (array[1] - 2 + 65).chr.to_s + (10 - array[0]).to_s
  end

  def valid_selection?(coords, valid_choice_list)
    valid_choice_list.include?(coords)
  end

  def pseudo_legal_moves(coords)
    pseudo_legal_moves_list = []

    piece = @positions[coords[0]][coords[1]].occupant
    piece_type = piece.class
    piece_color = piece.color

    piece.move_set.each do |direction|
      direction.each do |shift|
        move = [coords[0] + shift[0], coords[1] + shift[1]]
        new_square = @positions[move[0]][move[1]]

        break if new_square.nil?

        if new_square.occupant.is_a?(Piece)
          unless new_square.occupant.color == piece_color || piece_type == Pawn
            pseudo_legal_moves_list << move
          end
          break
        end

        pseudo_legal_moves_list << move
      end
    end

    if [Pawn, King].include?(piece_type)
      special_moves = special_movement(coords, piece, piece_type)
      special_moves.each { |move| pseudo_legal_moves_list << move }
    end

    pseudo_legal_moves_list
  end

  def special_movement(coords, piece, piece_type)
    special_moves = []

    if piece_type == Pawn
      %i[
        en_passant_availability
        pawn_capture_availability
        pawn_double_step_availability
      ].each do |method|
        send(method, coords, piece).each { |move| special_moves << move }
      end
    elsif piece_type == King
      castle_availability(coords, piece).each { |move| special_moves << move }
    end

    special_moves
  end

  def legal_moves(coords)
    legal_moves_list = []
    pseudo_legal_moves_list = pseudo_legal_moves(coords)

    piece = @positions[coords[0]][coords[1]].occupant
    return legal_moves_list unless piece.is_a?(Piece)

    defending_color = piece.color
    attacking_color = COLORS.find { |color| color != defending_color }

    pseudo_legal_moves_list.each do |move|
      end_position = [move[0], move[1]]
      make_move(piece, coords, end_position, move[2])
      legal_moves_list << move unless check?(attacking_color, defending_color)
      undo_move
    end

    legal_moves_list
  end

  def create_move(piece, start_position, end_position)
    { piece: piece, start_position: start_position, end_position: end_position }
  end

  def make_move(piece, start_position, end_position, special_case = nil)
    turn = []

    if special_case
      turn = send(special_case, piece, start_position, end_position)
    else
      occupant =
        @positions[end_position[0]][end_position[1]]
          .occupant unless end_position.nil?
      turn << create_move(piece, start_position, end_position)
      turn << create_move(occupant, end_position, nil) if occupant.is_a?(Piece)
    end

    update_board(turn, :forward)
    @moves_list << turn
  end

  def undo_move
    prev_move = @moves_list.pop
    update_board(prev_move, :reverse)
  end

  def update_board(turn, direction)
    method = direction == :forward ? :each : :reverse_each

    turn.public_send(method) do |move|
      update_move_count(move, direction)
      update_piece_list(move, direction)
      update_position(move, direction)
    end
  end

  def update_move_count(move, direction)
    piece = move[:piece]

    unless move[:start_position].nil? || move[:end_position].nil?
      direction == :forward ? (piece.move_count += 1) : (piece.move_count -= 1)
    end
  end

  def update_piece_list(move, direction)
    piece = move[:piece]
    start_position = move[:start_position]
    end_position = move[:end_position]
    color = piece.color

    case direction
    when :forward
      if end_position.nil?
        @piece_list[color].delete_if { |item| item[:piece] == piece }
      elsif start_position.nil?
        @piece_list[color] << { piece: piece, position: end_position }
      else
        index = @piece_list[color].index { |item| item[:piece] == piece }
        @piece_list[color][index][:position] = end_position
      end
    when :reverse
      if end_position.nil?
        @piece_list[color] << { piece: piece, position: start_position }
      elsif start_position.nil?
        @piece_list[color].delete_if { |item| item[:piece] == piece }
      else
        index = @piece_list[color].index { |item| item[:piece] == piece }
        @piece_list[color][index][:position] = start_position
      end
    end
  end

  def update_position(move, direction)
    piece = move[:piece]
    start_position = move[:start_position]
    end_position = move[:end_position]

    case direction
    when :forward
      if end_position.nil?
        if @positions[start_position[0]][start_position[1]].occupant == piece
          @positions[start_position[0]][start_position[1]].clear
        end
      elsif start_position.nil?
        @positions[end_position[0]][end_position[1]].occupant = piece
      else
        @positions[end_position[0]][end_position[1]].occupant = piece
        @positions[start_position[0]][start_position[1]].clear
      end
    when :reverse
      if end_position.nil?
        @positions[start_position[0]][start_position[1]].occupant = piece
      elsif start_position.nil?
        if @positions[end_position[0]][end_position[1]].occupant == piece
          @positions[end_position[0]][end_position[1]].clear
        end
      else
        @positions[start_position[0]][start_position[1]].occupant = piece
        if @positions[end_position[0]][end_position[1]].occupant == piece
          @positions[end_position[0]][end_position[1]].clear
        end
      end
    end
  end

  def attacked_by?(coords, piece_type, attacking_color, defending_color)
    piece = piece_type == Pawn ? Pawn.new(defending_color) : piece_type

    piece.capture_set.each do |direction|
      direction.each do |shift|
        move = [coords[0] + shift[0], coords[1] + shift[1]]
        new_square = @positions[move[0]][move[1]]

        break if new_square.nil?

        next unless new_square.occupant.is_a?(Piece)

        break unless new_square.occupant.color == attacking_color

        new_square.occupant.is_a?(piece_type) ? (return true) : break
      end
    end
    false
  end

  def check?(attacking_color, defending_color)
    sort_piece_lists unless @piece_list[defending_color][0][:piece].is_a?(King)

    king_position = @piece_list[defending_color][0][:position]

    PIECE_TYPES.any? do |piece_type|
      attacked_by?(king_position, piece_type, attacking_color, defending_color)
    end
  end

  def mate?(attacking_color, defending_color)
    check?(attacking_color, defending_color) && no_legal_moves?(defending_color)
  end

  def stalemate?(attacking_color, defending_color)
    !check?(attacking_color, defending_color) &&
      no_legal_moves?(defending_color)
  end

  def no_legal_moves?(color)
    piece_list[color].each do |hash|
      position = hash[:position]

      legal_moves_list = legal_moves(position)

      return false unless legal_moves_list.empty?
    end
    true
  end

  def castle_availability(coords, piece)
    available_moves = []

    defending_color = piece.color
    attacking_color = COLORS.find { |color| color != defending_color }

    if piece.move_count.zero? && !check?(attacking_color, defending_color)
      # short castling
      if castle_available?(coords, :short, attacking_color, defending_color)
        available_moves << [coords[0], coords[1] + 2, :castle]
      end

      # long castling
      if castle_available?(coords, :long, attacking_color, defending_color)
        available_moves << [coords[0], coords[1] - 2, :castle]
      end
    end

    available_moves
  end

  def castle_available?(coords, direction, attacking_color, defending_color)
    shift = direction == :short ? 1.upto(3) : -1.downto(-4)
    rook_pos = direction == :short ? 3 : -4

    shift.each_with_index do |step, index|
      if step == rook_pos
        piece = @positions[coords[0]][coords[1] + step].occupant
        return false unless piece.is_a?(Rook) && piece.move_count.zero?
      else
        if index.zero?
          if PIECE_TYPES.any? do |piece_type|
               attacked_by?(
                 [coords[0], coords[1] + step],
                 piece_type,
                 attacking_color,
                 defending_color
               )
             end
            return false
          end
        end
        return false unless @positions[coords[0]][coords[1] + step].empty?
      end
    end

    true
  end

  def castle(piece, start_position, end_position)
    king_move = create_move(piece, start_position, end_position)
    rank = start_position[0]

    if end_position[1] > start_position[1]
      rook = @positions[rank][9].occupant
      rook_start_position = [rank, 9]
      rook_end_position = [rank, 7]
    else
      rook = @positions[rank][2].occupant
      rook_start_position = [rank, 2]
      rook_end_position = [rank, 5]
    end

    rook_move = create_move(rook, rook_start_position, rook_end_position)

    [king_move, rook_move]
  end

  def en_passant_availability(coords, piece)
    available_moves = []
    return available_moves if moves_list.empty?

    prev_move = @moves_list.last[0]

    if piece.is_a?(Pawn) && !prev_move.nil? && prev_move[:piece].is_a?(Pawn) &&
         prev_move[:end_position][0] == coords[0] &&
         (prev_move[:end_position][1] - coords[1]).abs == 1 &&
         (prev_move[:end_position][0] - prev_move[:start_position][0]).abs == 2
      available_moves << [
        coords[0] + piece.move_set[0][0][0],
        prev_move[:end_position][1],
        :en_passant
      ]
    end

    available_moves
  end

  def en_passant(piece, start_position, end_position)
    attack_move = create_move(piece, start_position, end_position)

    captured_position = [start_position[0], end_position[1]]
    captured_piece =
      @positions[captured_position[0]][captured_position[1]].occupant

    captured_move = create_move(captured_piece, captured_position, nil)

    [attack_move, captured_move]
  end

  def pawn_capture_availability(coords, piece)
    available_moves = []

    piece.capture_set.each do |direction|
      direction.each do |shift|
        move = [coords[0] + shift[0], coords[1] + shift[1]]
        new_square = @positions[move[0]][move[1]]

        if new_square&.occupant.is_a?(Piece) &&
             new_square.occupant.color != piece.color
          available_moves << (move << :pawn_capture)
        end
      end
    end

    available_moves
  end

  def pawn_capture(piece, start_position, end_position)
    attack_move = create_move(piece, start_position, end_position)

    captured_piece = @positions[end_position[0]][end_position[1]].occupant

    captured_move = create_move(captured_piece, end_position, nil)

    [attack_move, captured_move]
  end

  def pawn_double_step_availability(coords, piece)
    unless piece.move_count.zero? &&
             @positions[coords[0] + piece.move_set[0][0][0]][coords[1]]
               .empty? &&
             @positions[coords[0] + piece.move_set[0][0][0] * 2][coords[1]]
               .empty?
      return []
    end

    [[coords[0] + piece.move_set[0][0][0] * 2, coords[1], :pawn_double_step]]
  end

  def pawn_double_step(piece, start_position, end_position)
    [create_move(piece, start_position, end_position)]
  end

  def promote_available?
    return false if moves_list.empty?

    prev_turn = @moves_list.last
    prev_turn.each do |move|
      piece = move[:piece]

      next unless piece.is_a?(Pawn)

      next if move[:end_position].nil?

      if (piece.color == :white && move[:end_position][0] == 2) ||
           (piece.color == :black && move[:end_position][0] == 9)
        return true
      end
    end
    false
  end

  def promote(replacement)
    return unless replacement.between?(1, 4)

    prev_turn = @moves_list.last
    return if prev_turn.nil?

    prev_move = prev_turn.find { |move| move[:piece].is_a?(Pawn) }
    return if prev_move.nil?

    old_piece = prev_move[:piece]
    end_position = prev_move[:end_position]
    new_piece =
      [Queen, Rook, Bishop, Knight][replacement - 1].new(old_piece.color)
    turn = []

    turn << create_move(old_piece, end_position, nil)
    turn << create_move(new_piece, nil, end_position)

    update_board(turn, :forward)
    turn.each { |move| prev_turn << move }
  end

  ################################################################

  def all_possible_moves
    start = Time.now
    @piece_list.each_value do |list|
      list.each do |piece|
        # p "Piece: #{piece}

        # p "Pseudo-legal moves: #{pseudo_moves}"
        legal_moves = legal_moves(piece[:position])
        p "Legal moves: #{legal_moves}"
      end
    end
    fin = Time.now
    time = fin - start
    puts time
  end
end

# attacking_color = COLORS.find { |color| color != defending_color }

# moves_list.each do |move|
#   @positions[move[0]][move[1]].background_color = CAPTURE_SQUARE
# end

################################################################

# @board = Board.new
# @piece = Pawn.new(:black)

# @board.moves_list << {
#   piece: @piece,
#   start_position: [3, 6],
#   end_position: [5, 6]
# }

# @board.positions[3][6].occupant = ' '
# @board.positions[9][8].occupant = ' '
# @board.positions[9][7].occupant = ' '
# @board.positions[9][5].occupant = ' '
# @board.positions[9][4].occupant = ' '
# @board.positions[9][3].occupant = ' '
# @board.positions[8][5].occupant = ' '
# @board.positions[8][4].occupant = ' '
# @board.positions[8][6].occupant = ' '
# @board.positions[8][7].occupant = ' '
# @board.positions[8][8].occupant = ' '
# @board.positions[5][6].occupant = @piece
# @white_pawn = Pawn.new(:white)
# @board.positions[5][5].occupant = @white_pawn
# @board.piece_list[:white] << { piece: @white_pawn, position: [5, 5] }
# @board.positions[8][8].occupant = Pawn.new(:black)

# # @special_moves = @board.special_movement([8, 5], @piece, Pawn)

# pieces = [
#   # [Queen, [7, 4], :black],
#   # [Rook, [7, 6], :black]
#   # [Queen, [4, 5], :white]
# ]
# pieces.each do |piece|
#   @board.positions[piece[1][0]][piece[1][1]].occupant = piece[0].new(piece[2])
# end

# pseudo_legal_moves_list = @board.pseudo_legal_moves([5, 5])
# p "Pseudo-legal moves: #{pseudo_legal_moves_list}"

# start = Time.now
# legal_moves_list = @board.legal_moves([5, 5])
# fin = Time.now
# time = fin - start
# p "Time: #{time}"
# p "Legal moves: #{legal_moves_list}"

# # legal_moves_list.each do |move|
# #   @board.positions[move[0]][move[1]].background_color = :on_red
# # end

# # start = Time.now
# # @board.check?(:black, :white)
# # fin = Time.now
# # time = fin - start
# # puts time
# @board.display
# @pawn = @board.positions[8][3].occupant
# @board.make_move(@pawn, [8, 3], [5, 6])

# @board.display
