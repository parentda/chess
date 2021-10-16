# frozen_string_literal: true
require_relative 'piece'

class Pawn < Piece
  @@movement = [-1, 0, 1]
  @@symbol = "\u265F"

  def move_set
    @@move_set ||=
      @@movement
        .repeated_permutation(2)
        .reject { |pair| pair[1].zero? }
        .map do |pair|
          move_list = [pair]
          move_list << pair.map { |n| n * 2 } if pair[0].zero?
          move_list
        end
  end

  def symbol
    @@symbol
  end
end
