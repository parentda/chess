require 'pry-byebug'
require 'require_all'
require_rel '../pieces'
require_rel 'square'
require_rel '../move'

class Board
  attr_accessor :positions, :piece_list, :moves_list

  SIZE = 8
  COLORS = %i[white black].freeze

  LIGHT_SQUARE = :on_light_yellow
  DARK_SQUARE = :on_yellow
  CAPTURE_SQUARE = :on_red
  MOVE_MARKER = "\u25CF".blue

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

  def display
    output = ''
    @positions.each_with_index do |row, i|
      next if row[2].nil?

      output << "\t#{SIZE + 2 - i} "
      row.each { |square| output << square.to_string unless square.nil? }
      output << "\n"
    end
    output << "\t  "
    ('a'..'h').each { |letter| output << " #{letter} " }

    # system 'clear'
    puts output
  end

  def valid_input?(string)
    return false unless string.length == 2

    string.match?(/[a-h][1-8]/i)
  end

  def convert_input(string)
    row = 10 - string[1].to_i
    col = (string[0].downcase.ord - 97) + 2
    [row, col]
  end

  def valid_selection(coords, valid_choice_list)
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
          unless new_square.occupant.color == piece_color
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

  def legal_moves(coords, pseudo_legal_moves_list)
    legal_moves_list = []

    pseudo_legal_moves_list.each do |move|
      make_move
      legal_moves_list << move unless check?
      undo_move
    end

    legal_moves_list
  end

  def create_move(start_position, end_position); end

  def make_move(start_position, end_position, special_case = nil); end

  def undo_move; end

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
    king_position = @piece_list[defending_color][0][:position]

    PIECE_TYPES.any? do |piece_type|
      attacked_by?(king_position, piece_type, attacking_color, defending_color)
    end
  end

  def mate?(attacking_color, defending_color); end

  def stalemate?(attacking_color, defending_color); end

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
    rook_pos = shift.max

    shift.each_with_index do |step, index|
      if step == rook_pos
        unless @positions[coords[0]][coords[1] + step].occupant.move_count.zero?
          return false
        end
      elsif step < rook_pos
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
      end
      return false unless @positions[coords[0]][coords[1] + step].empty?
    end

    true
  end

  def castle; end

  def en_passant_availability(coords, piece)
    available_moves = []
    prev_move = @moves_list.last

    if piece.is_a?(Pawn) && prev_move[:piece].is_a?(Pawn) &&
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

  def en_passant; end

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

  def pawn_capture; end

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

  def pawn_double_step; end

  def promotion_available?; end

  def promotion; end
end

# attacking_color = COLORS.find { |color| color != defending_color }

# moves_list.each do |move|
#   @positions[move[0]][move[1]].background_color = CAPTURE_SQUARE
# end

@board = Board.new
@piece = Pawn.new(:black)

@board.moves_list << {
  piece: @piece,
  start_position: [3, 6],
  end_position: [5, 6]
}

@board.positions[3][6].occupant = ' '
@board.positions[5][6].occupant = @piece
@board.positions[5][5].occupant = Pawn.new(:white)

# @special_moves = @board.special_movement([8, 5], @piece, Pawn)

pieces = [
  [Queen, [7, 4], :black],
  [Rook, [7, 6], :black]
  # [Queen, [4, 5], :white]
]
pieces.each do |piece|
  @board.positions[piece[1][0]][piece[1][1]].occupant = piece[0].new(piece[2])
end

pseudo_legal_moves_list = @board.pseudo_legal_moves([5, 5])
p pseudo_legal_moves_list

pseudo_legal_moves_list.each do |move|
  @board.positions[move[0]][move[1]].background_color = :on_red
end

@board.display
