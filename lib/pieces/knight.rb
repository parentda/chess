# frozen_string_literal: true
require_relative 'piece'

class Knight < Piece
  @@movement = [2, 1, -1, -2]
  @@symbol = "\u265E"
  @@value = 3

  def self.move_set
    @@move_set ||=
      @@movement
        .permutation(2)
        .reject { |pair| pair[0].abs == pair[1].abs }
        .map { |pair| [pair] }
  end

  class << self
    alias capture_set move_set
  end

  def symbol
    @@symbol
  end

  def value
    @@value
  end
end
