# frozen_string_literal: true
require_relative 'piece'

class Knight < Piece
  @@movement = [2, 1, -1, -2]

  attr_reader :symbol, :move_set

  def initialize(color)
    super
    @symbol = "\u2658"
    @move_set ||=
      @@movement.permutation(2).reject { |pair| pair[0].abs == pair[1].abs }
  end
end
