# frozen_string_literal: true
require 'colorize'

class Piece
  def initialize(color)
    @move_count = 0
    @color = color
    move_set
  end

  def to_s
    @color == :white ? symbol.white : symbol.black
  end
end
