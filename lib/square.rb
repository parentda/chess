# frozen_string_literal: true
require 'colorize'

class Square
  attr_accessor :occupant

  def initialize(background_color, occupant = ' ')
    @occupant = occupant
    @background_color = background_color
  end

  def to_string
    @occupant.to_s.send(@background_color)
  end
end
