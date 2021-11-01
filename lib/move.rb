class Move
  attr_reader :piece, :start_position, :end_position

  def initialize(piece, start_position, end_position)
    @piece = piece
    @start_position = start_position
    @end_position = end_position
  end
end
