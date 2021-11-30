require_relative 'board/board'
require_relative 'display/class_displayable'
require_relative 'display/instance_displayable'

class Game
  include InstanceDisplayable
  extend ClassDisplayable

  attr_reader :players, :current_player, :game_over, :board

  @@saved_games_folder = 'saved_games'

  def initialize(game_mode)
    @board = Board.new
    @players = []
    @current_player = nil
    @game_over = false
    @game_won = false
    @game_mode = game_mode
    @setup_complete = false
  end

  def self.user_input(
    prompt,
    warning,
    match_criteria,
    negate_matcher = false,
    input_modifier = nil
  )
    puts prompt
    input = gets.chomp.upcase
    raise warning unless input.match?(match_criteria)

    input
  rescue StandardError => e
    puts e
    retry
  end

  def self.open_saved_file
    saved_games = find_saved_files
    return saved_games if saved_games.nil?

    display_saved_files(saved_games)
    file_num = get_file_num(saved_games)
    load_game_prompt(saved_games[file_num])
    load_saved_file("#{@@saved_games_folder}/#{saved_games[file_num]}")
  end

  def self.find_saved_files
    saved_games = Dir.glob('*.yaml', base: @@saved_games_folder)
    if saved_games.empty?
      puts no_saved_games_prompt
      return nil
    end
    Hash[(1..saved_games.size).zip saved_games]
  end

  def self.display_saved_files(hash)
    puts display_saved_games(hash)
  end

  def self.load_saved_file(filepath)
    saved_game = File.read(filepath)
    YAML.load(saved_game)
  end

  def self.get_file_num(games_list)
    user_input(saved_game_prompt, warning_prompt_invalid, /#{games_list.keys}/)
      .to_i
  end

  def self.game_load
    user_input(game_load_prompt, warning_prompt_invalid, /[1-2]/)
  end

  def self.game_mode
    user_input(game_mode_prompt, warning_prompt_invalid, /[1-3]/)
  end

  def self.create_game
    intro_message
    loop do
      mode = game_load
      if mode == '1'
        new_game_message
        return new(mode)
      else
        loaded_game = open_saved_file
        return loaded_game unless loaded_game.nil?
      end
    end
  end

  def self.restart
    restart_message
    gets.chomp.downcase == 'y'
  end

  def self.close
    close_message
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
    @game_won ? win_prompt(@current_player) : tie_prompt
  end

  def save
    serialized_file = serialize
    Dir.mkdir(@@saved_games_folder) unless Dir.exist?(@@saved_games_folder)
    filename = "#{Game.user_input}.yaml"
    filepath = "#{@@saved_games_folder}/#{filename}"
    File.write(filepath, serialized_file)
    puts save_game_message(filename)
  end

  def serialize
    YAML.dump(self)
  end
end
