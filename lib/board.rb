class Board
  attr_reader :positions

  def initialize()
    @positions = Array.new(8) { Array.new(8) }
  end
end
