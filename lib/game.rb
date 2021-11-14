require_relative '../board'

class Game
  include Displayable

  attr_reader :players, :current_player, :game_over, :board

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

  def game_setup
    return if @setup_complete

    segment_break_prompt
    introduction_prompt(@board)
    @num_players.times { |num| create_player(num) }
    @current_player = @players.first
    game_start_prompt(@board, @players)
  end
end
