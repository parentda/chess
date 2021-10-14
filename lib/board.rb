# frozen_string_literal: true
require 'require_all'
require_rel 'pieces'

class Board
  attr_reader :positions
  FIRST_RANK = [Rook, Knight, Bishop, Queen, King, Bishop, Knight, Rook].freeze
  SECOND_RANK = [Pawn, Pawn, Pawn, Pawn, Pawn, Pawn, Pawn, Pawn].freeze

  def initialize
    @size = 8
    @positions = Array.new(@size) { Array.new(@size) }
  end

  def populate_positions
    FIRST_RANK.each_with_index do |piece, index|
      @positions[0][index] = piece.new('B')
      @positions[-1][index] = piece.new('W')
    end

    SECOND_RANK.each_with_index do |piece, index|
      @positions[1][index] = piece.new('B')
      @positions[-2][index] = piece.new('W')
    end
  end
end
