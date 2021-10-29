# frozen_string_literal: true
require_relative 'piece'

class Pawn < Piece
  @@movement = [-1, 0, 1]
  @@symbol = "\u265F"
  @@value = 1

  def self.move_set
    @move_set ||=
      if @color == :black
        @@movement
          .repeated_permutation(2)
          .reject { |pair| pair[0] <= 0 }
          .map do |pair|
            move_list = [pair]
            move_list << pair.map { |n| n * 2 } if pair[1].zero?
            move_list
          end
      else
        @@movement
          .repeated_permutation(2)
          .reject { |pair| pair[0] >= 0 }
          .map do |pair|
            move_list = [pair]
            move_list << pair.map { |n| n * 2 } if pair[1].zero?
            move_list
          end
      end
  end

  def symbol
    @@symbol
  end

  def value
    @@value
  end
end
