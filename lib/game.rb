class Game
  def initialize
    @board = Board.new
    @players = []
    @current_player = nil
    @game_over = false
    @setup_complete = false
  end

  def play
    game_setup
    game_loop
    game_end
  end
end
