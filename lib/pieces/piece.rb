# frozen_string_literal: true
require 'colorize'

class Piece
  attr_reader :color, :move_count

  def initialize(color)
    @move_count = 0
    @color = color
    move_set
  end

  def self.move_set; end

  def move_set
    self.class.move_set
  end

  alias capture_set move_set

  def to_s
    @color == :white ? symbol.white : symbol.black
  end
end
