class Board
  attr_reader :positions

  def initialize()
    @size = 8
    @positions = Array.new(@size) { Array.new(@size) }
  end
end
