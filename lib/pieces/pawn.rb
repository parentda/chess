# frozen_string_literal: true
require_relative 'piece'

class Pawn < Piece
  @@movement = [-1, 0, 1]
  @@symbol = "\u265F"
  @@value = 1

  def move_set
    @move_set ||= @color == :black ? [[[1, 0]]] : [[[-1, 0]]]
  end

  def capture_set
    @capture_set ||=
      @color == :black ? [[[1, 1], [1, -1]]] : [[[-1, 1], [-1, -1]]]
  end

  def symbol
    @@symbol
  end

  def value
    @@value
  end
end
