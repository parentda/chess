# frozen_string_literal: true
require 'colorize'

class Square
  attr_accessor :occupant, :background_color

  def initialize(background_color, occupant = ' ')
    @occupant = occupant
    @background_color = background_color
  end

  def empty?
    @occupant == ' '
  end

  def to_string
    " #{@occupant} ".send(@background_color)
  end
end
