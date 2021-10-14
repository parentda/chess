# frozen_string_literal: true
require_relative 'piece'

class Queen < Piece
  @@movement = [-1, 0, 1]

  def initialize(color)
    super
    @symbol = "\u265B"
  end

  def self.move_set
    @@move_set ||=
      @@movement
        .repeated_permutation(2)
        .reject { |pair| pair == [0, 0] }
        .map do |pair|
          move_list = [pair]
          (2..7).each { |i| move_list << pair.map { |n| n * i } }
          move_list
        end
  end
end
