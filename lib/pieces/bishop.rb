# frozen_string_literal: true
require_relative 'piece'

class Bishop < Piece
  @@movement = [-1, 0, 1]

  def initialize(color)
    super
    @symbol = "\u265D"
  end

  def self.move_set
    @@move_set ||=
      @@movement
        .repeated_permutation(2)
        .filter { |pair| pair[0].abs.eql?(1) && pair[1].abs.eql?(1) }
        .map do |pair|
          move_list = [pair]
          (2..7).each { |i| move_list << pair.map { |n| n * i } }
          move_list
        end
  end
end
