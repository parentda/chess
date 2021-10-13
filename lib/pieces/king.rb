# frozen_string_literal: true
require_relative 'piece'

class King < Piece
  @@movement = [-1, 0, 1]

  attr_reader :symbol, :move_set

  def initialize(color)
    super
    @symbol = "\u2654"
    @move_set ||=
      @@movement.repeated_permutation(2).reject { |pair| pair == [0, 0] }
  end
end
