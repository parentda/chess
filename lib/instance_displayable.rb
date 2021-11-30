module InstanceDisplayable
  SECTION_BREAK = '-' * 100

  def intro_message
    puts <<~HEREDOC
    
    #{SECTION_BREAK}

    Welcome to #{'CHESS'.blue}!
    
    If you do not know the rules of chess, please familiarize yourself with them at the following link:

      http://www.chessvariants.org/d.chess/chess.html
    

    Each turn requires two separate inputs:

      1 - Coordinates of the piece to move
      2 - Coordinates of a legal move for the selected piece
    HEREDOC
  end

  def restart_message
    puts "\n\nWould you like to play again? Enter (Y/y) to start a new game/load a saved game, or any other key to quit:"
  end

  def close_message
    puts "\nThanks for playing!"
  end

  def save_game_message(filepath)
    puts "\nYour game has been saved as:  #{filepath.blue}"
  end

  def display_saved_games(hash)
    output = ''
    hash.each { |key, value| output += "#{key.to_s.blue}:  #{value}\n" }

    <<~HEREDOC

    Saved Games:
    
    #{output}
    HEREDOC
  end

  def new_game_message
    <<~HEREDOC

    Starting new game...
    #{SECTION_BREAK}
    HEREDOC
  end

  def load_game_message(filename)
    <<~HEREDOC

    Loading #{filename}...
    #{SECTION_BREAK}
    HEREDOC
  end

  def game_load_prompt
    <<~HEREDOC
    Would you like to start a new game or load a saved game?

    1 - Start a new game
    2 - Load a previously saved game
    HEREDOC
  end

  def game_mode_prompt
    <<~HEREDOC
    Please select one of the following game modes:

    1 - Player vs. Player
    2 - Player vs. Computer
    3 - Computer vs. Computer
    HEREDOC
  end

  def select_color_prompt
    <<~HEREDOC
    Please select the player color:

    1 - White
    2 - Black
    HEREDOC
  end

  def saved_game_prompt
    'Please input a number corresponding to a file listed above: '
  end

  def no_saved_games_prompt
    "\nThere are no saved games. Please start a new game.".red
  end

  def warning_prompt_invalid
    "\nSorry, that input is invalid".red
  end

  def piece_select_prompt; end

  def move_select_prompt; end
end
