require 'require_all'
require_rel '../pieces'
require_rel 'square'
require_rel '../move'

class Board
  attr_accessor :positions, :piece_list

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

  def create_move(start_position, end_position); end

  def make_move(start_position, end_position, special_case); end

  def undo_move; end

  def pseudo_legal_moves(coords)
    pseudo_legal_moves_list = []

    piece = @positions[coords[0]][coords[1]].occupant
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

    # moves_list.each do |move|
    #   @positions[move[0]][move[1]].background_color = CAPTURE_SQUARE
    # end

    pseudo_legal_moves_list
  end

  def legal_moves(coords, pseudo_legal_moves_list)
    legal_moves_list = []

    pseudo_legal_moves.each do |move|
      make_move
      check?
      undo_move
    end

    legal_moves_list
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
    king_position = @piece_list[defending_color][0][:position]

    PIECE_TYPES.any? do |piece_type|
      attacked_by?(king_position, piece_type, attacking_color, defending_color)
    end
  end
end

# attacking_color = COLORS.find { |color| color != defending_color }
