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

  def self.open_saved_file
    saved_games = find_saved_files
    return saved_games if saved_games.nil?

    display_saved_files(saved_games)
    file_num = get_file_num(saved_games)
    puts load_game_prompt(saved_games[file_num])
    load_saved_file("#{@@saved_games_folder}/#{saved_games[file_num]}")
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

  def game_loop
    until @board.full?
      player_turn
      return @game_over = true if @board.game_over?

      switch_player
    end
  end

  def player_turn
    column = player_input
    @board.update_board(column, @current_player.marker)
    @board.display
  end

  def undo_turn; end

  def switch_player
    @players.rotate!
    @current_player = @players.first
  end

  def game_end
    @game_over ? win_prompt(@current_player) : tie_prompt
  end

  def save
    serialized_file = serialize
    Dir.mkdir(@@saved_games_folder) unless Dir.exist?(@@saved_games_folder)
    filename = "#{@output_array.join(' ')}.yaml"
    filepath = "#{@@saved_games_folder}/#{filename}"
    File.write(filepath, serialized_file)
    puts save_game_message(filename)
  end

  def serialize
    YAML.dump(self)
  end
end
