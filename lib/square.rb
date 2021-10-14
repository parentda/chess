# frozen_string_literal: true
require 'colorize'

class Square
  def initialize(background_color, symbol = ' ')
    @symbol = symbol
    @background_color = background_color
  end

  def to_string
    @symbol.to_s.send(@background_color)
  end
end
