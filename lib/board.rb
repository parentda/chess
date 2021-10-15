require 'require_all'
require_rel 'pieces'
require_rel 'square'

class Board
  attr_reader :positions

  SIZE = 8
  LIGHT_SQUARE = :on_light_yellow
  DARK_SQUARE = :on_yellow
  FIRST_RANK = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].freeze
  SECOND_RANK = Array.new(SIZE, Pawn).freeze

  def initialize
    @positions = Array.new(SIZE) { Array.new(SIZE) }
    populate_grid
    populate_pieces
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
      @positions[0][index].occupant = piece.new('B')
      @positions[-1][index].occupant = piece.new('W')
    end

    SECOND_RANK.each_with_index do |piece, index|
      @positions[1][index].occupant = piece.new('B')
      @positions[-2][index].occupant = piece.new('W')
    end
  end

  def display
    output = ''
    @positions.each do |row|
      row.each { |square| output << square.to_string }
      output << "\n"
    end
    output
  end
end
