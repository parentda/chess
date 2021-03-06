require_relative 'board/board'
require_relative 'display/class_displayable'
require_relative 'display/instance_displayable'
require_rel 'players'

class Game
  include InstanceDisplayable
  extend ClassDisplayable

  attr_reader :players, :game_over, :board

  ROWS = %w[1 2 3 4 5 6 7 8].freeze
  COLUMNS = %w[a b c d e f g h].freeze
  POSITIONS = COLUMNS.product(ROWS).map { |arr| arr[0] + arr[1] }.freeze

  COMMANDS = %w[save quit].freeze

  @@saved_games_folder = 'saved_games'

  def initialize(game_mode, players)
    @board = Board.new
    @players = players
    @game_over = false
    @game_mode = game_mode
    @turns = 0
    @turn_limit = 100
  end

  def self.user_input(prompt, warning, match_criteria, negate_matcher = false)
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
    load_game_message(saved_games[file_num])
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
    user_input(
      saved_game_prompt,
      warning_prompt_invalid,
      games_list.keys.map(&:to_s)
    ).to_i
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
    system 'clear'

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
      [Computer.new(Board::COLORS[0]), Computer.new(Board::COLORS[1])]
    when '4'
      [Computer.new(Board::COLORS[0]), Human.new(Board::COLORS[1])]
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
      return if @game_over

      switch_player
    end
  end

  def player_turn
    check_status = @board.check?(@players.last.color, @players.first.color)

    display(check_status)

    position = position_select
    return if @game_over

    coords = position_to_array(position)
    moves_list = @board.legal_moves(coords)

    display(check_status, coords, moves_list)

    move = move_select(moves_list)
    return if @game_over

    commit_move(move, coords, moves_list)
    @turns += 1

    display(check_status)

    promotion_availability(check_status)
    check_game_over
  end

  def display(check_status, selected_coords = nil, moves_list = nil)
    system 'clear'

    save_quit_message
    coordinate_format_message
    segment_break
    elapsed_turns_message(@turns)
    color_prompt_message(@players.first.color)
    @board.display(selected_coords, moves_list)
    check_message(@players.first.color) if check_status
  end

  def position_select
    legal_piece_list =
      @board
        .legal_pieces(@players.first.color)
        .map { |coord| array_to_position(coord) }

    turn_input(:piece_select_prompt, legal_piece_list)
  end

  def move_select(moves_list)
    turn_input(
      :piece_select_prompt,
      moves_list.map { |coord| array_to_position(coord) }
    )
  end

  def commit_move(move, coords, moves_list)
    move_coords =
      moves_list.select { |coord| coord.first(2) == position_to_array(move) }
        .first

    piece = @board.positions[coords[0]][coords[1]].occupant
    @board.make_move(piece, coords, move_coords.first(2), move_coords[2])
  end

  def promotion_availability(check_status)
    if @board.promote_available?
      if @players.first.is_a?(Human)
        promotion_choice =
          Game.user_input(
            promotion_prompt,
            Game.warning_prompt_invalid,
            %w[1 2 3 4]
          ).to_i
        @board.promote(promotion_choice)
      else
        @board.promote(1)
      end
      display(check_status)
    end
  end

  def turn_input(prompt, match_list)
    if @players.first.is_a?(Human)
      loop do
        input =
          Game.user_input(
            method(prompt).call,
            Game.warning_prompt_invalid,
            match_list + COMMANDS
          )
        return @game_over = :resign if input == 'quit'

        return input unless input == 'save'

        save
      end
    else
      sleep(0.7)
      match_list.sample
    end
  end

  def check_game_over
    @game_over =
      @board.check_game_over(@players.first.color, players.last.color)

    @game_over = :draw if @turns >= @turn_limit

    unless @board.check_piece_discrepancy
      raise StandardError.new('Board positions and piece lists out of sync')
    end
  end

  def switch_player
    @players.rotate!
  end

  def game_end
    case @game_over
    when :checkmate
      checkmate_message(@players.first.color)
    when :stalemate
      stalemate_message(@players.last.color)
    when :draw
      draw_message(@turn_limit)
    else
      resign_message(@players.first.color)
    end
  end

  def save
    serialized_file = serialize
    Dir.mkdir(@@saved_games_folder) unless Dir.exist?(@@saved_games_folder)
    filename =
      "#{Game.user_input(save_game_prompt, warning_prompt_invalid, [], true)}.yaml"
    filepath = "#{@@saved_games_folder}/#{filename}"
    File.write(filepath, serialized_file)
    save_game_message(filename)
  end

  def serialize
    YAML.dump(self)
  end

  def position_to_array(string)
    row = 10 - string[1].to_i
    col = (string[0].downcase.ord - 97) + 2
    [row, col]
  end

  def array_to_position(array)
    (array[1] - 2 + 97).chr.to_s + (10 - array[0]).to_s
  end
end
