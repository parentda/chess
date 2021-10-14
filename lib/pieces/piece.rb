# frozen_string_literal: true
require 'colorize'

class Piece
  attr_reader :symbol

  def initialize(color)
    @move_count = 0
    @color = color
  end

  def to_string
    @color == 'W' ? @symbol.white : @symbol.black
  end
end
