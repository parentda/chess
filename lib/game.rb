class Game
  def initialize
    @game_over = false
    @setup_complete = false
  end

  def play
    game_setup
    game_loop
    game_end
  end
end
