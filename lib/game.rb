require_relative 'board/board'
require_relative 'display/class_displayable'
require_relative 'display/instance_displayable'
require_rel 'players'

class Game
  include InstanceDisplayable
  extend ClassDisplayable

  attr_reader :players, :current_player, :game_over, :board

  ROWS = %w[1 2 3 4 5 6 7 8].freeze
  COLUMNS = %w[a b c d e f g h].freeze
  POSITIONS = COLUMNS.product(ROWS).map { |arr| arr[0] + arr[1] }.freeze

  COMMANDS = %w[save quit undo].freeze

  @@saved_games_folder = 'saved_games'

  def initialize(game_mode, players)
    @board = Board.new
    @players = players
    @current_player = @players.first
    @game_over = false
    @game_won = false
    @game_mode = game_mode
  end

  def self.user_input(
    prompt,
    warning,
    match_criteria,
    negate_matcher = false,
    input_modifier = nil
  )
    prompt

    begin
      input = gets.chomp.downcase

      if negate_matcher
        raise warning if match_criteria.include?(input)
      else
        raise warning unless match_criteria.include?(input)
      end

      input
    rescue StandardError => e
      puts e
      retry
    end
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
    user_input(saved_game_prompt, warning_prompt_invalid, games_list.keys).to_i
  end

  def self.input_game_load
    user_input(game_load_prompt, warning_prompt_invalid, %w[1 2])
  end

  def self.input_game_mode
    user_input(game_mode_prompt, warning_prompt_invalid, %w[1 2 3])
  end

  def self.input_player_color
    user_input(select_color_prompt, warning_prompt_invalid, %w[1 2])
  end

  def self.create_game
    segment_break
    intro_message

    loop do
      game_load = input_game_load

      return game_setup if game_load == '1'

      loaded_game = open_saved_file
      return loaded_game unless loaded_game.nil?
    end
  end

  def self.game_setup
    game_mode = input_game_mode

    if game_mode == '2'
      player_color = input_player_color
      game_mode = player_color == '1' ? '2' : '4'
    end

    players_list = create_players(game_mode)
    new_game_message
    segment_break

    new(game_mode, players_list)
  end

  def self.create_players(game_mode)
    case game_mode
    when '1'
      [Human.new(Board::COLORS[0]), Human.new(Board::COLORS[1])]
    when '2'
      [Human.new(Board::COLORS[0]), Computer.new(Board::COLORS[1])]
    when '3'
      [Computer.new(Board::COLORS[0]), Human.new(Board::COLORS[1])]
    when '4'
      [Computer.new(Board::COLORS[0]), Computer.new(Board::COLORS[1])]
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
    game_loop
    game_end
  end

  def game_loop
    loop do
      player_turn
      return @game_over = true if @board.game_over?

      switch_player
    end
  end

  def player_turn
    display

    legal_piece_list = @board.legal_pieces(@current_player.color)

    puts "Piece List: #{legal_piece_list}"

    piece = piece_select(legal_piece_list)

    moves_list = @board.legal_moves(@board.position_to_array(piece))

    display(@board.position_to_array(piece), moves_list)
    puts "Piece: #{piece}"
    puts "Moves List: #{moves_list}"

    move =
      move_select(moves_list.map { |coord| @board.array_to_position(coord) })

    case player_input
    when 'SAVE'
      save
      false
    when 'QUIT'
      false
    else
      evaluate_guess(player_input)
      puts display_output
      true
    end

    @board.update_board(column, @current_player.marker)

    @game_over = @board.check_game_over
  end

  def display(selected_coords = nil, moves_list = nil)
    system 'clear'

    color_prompt =
      if @current_player.color == Board::COLORS[0]
        '  WHITE to move  '.black.on_white
      else
        '  BLACK to move  '.white.on_black
      end

    save_quit_message
    coordinate_format_message
    color_prompt_message(color_prompt)
    @board.display(selected_coords, moves_list)
  end

  def piece_select(piece_list)
    Game.user_input(
      piece_select_prompt,
      Game.warning_prompt_invalid,
      piece_list
    )
  end

  def move_select(move_list)
    Game.user_input(move_select_prompt, Game.warning_prompt_invalid, move_list)
  end

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
    save_game_message(filename)
  end

  def quit; end

  def serialize
    YAML.dump(self)
  end
end
