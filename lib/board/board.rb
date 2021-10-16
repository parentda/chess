require 'require_all'
require_rel '../pieces'
require_rel 'square'

class Board
  attr_reader :positions

  SIZE = 8
  WHITE = :white
  BLACK = :black

  LIGHT_SQUARE = :on_light_yellow
  DARK_SQUARE = :on_yellow
  CAPTURE_SQAURE = :on_red
  MOVE_MARKER = "\u25CF".blue

  FIRST_RANK = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].freeze
  SECOND_RANK = Array.new(SIZE, Pawn).freeze

  def initialize
    @positions = Array.new(SIZE) { Array.new(SIZE) }
    populate_grid
    populate_pieces
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
    FIRST_RANK.each_with_index do |piece, index|
      @positions[0][index].occupant = piece.new(BLACK)
      @positions[-1][index].occupant = piece.new(WHITE)
    end

    SECOND_RANK.each_with_index do |piece, index|
      @positions[1][index].occupant = piece.new(BLACK)
      @positions[-2][index].occupant = piece.new(WHITE)
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
    system 'clear'
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
end
