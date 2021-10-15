# frozen_string_literal: true
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
    count = 1
    @positions.each_with_index do |row, i|
      row.each_with_index do |_square, j|
        @positions[i][j] =
          count.odd? ? Square.new(LIGHT_SQUARE) : Square.new(DARK_SQUARE)
        count += 1
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
end
