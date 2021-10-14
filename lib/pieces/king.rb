# frozen_string_literal: true
require_relative 'piece'

class King < Piece
  @@movement = [-1, 0, 1]

  def initialize(color)
    super
    @symbol = "\u265A"
  end

  def self.move_set
    @@move_set ||=
      @@movement
        .repeated_permutation(2)
        .reject { |pair| pair == [0, 0] }
        .map { |pair| [pair] }
  end
end
