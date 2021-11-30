module ClassDisplayable
  SECTION_BREAK = '-' * 100

  def intro_message
    puts <<~HEREDOC
    
    #{SECTION_BREAK}

    Welcome to #{'CHESS'.blue}!
    
    If you do not know the rules of chess, please familiarize yourself with them at the following link:

      http://www.chessvariants.org/d.chess/chess.html
    
    Each turn requires two separate inputs:

      [1] Coordinates of the piece to move
      [2] Coordinates of a legal move for the selected piece

    HEREDOC
  end

  def display_saved_games(hash)
    output = ''
    hash.each { |key, value| output += "#{key.to_s.blue}:  #{value}\n" }

    puts <<~HEREDOC

    Saved Games:
    
    #{output}
    HEREDOC
  end

  def new_game_message
    puts <<~HEREDOC

    Starting new game...
    #{SECTION_BREAK}
    HEREDOC
  end

  def load_game_message(filename)
    puts <<~HEREDOC

    Loading #{filename}...
    #{SECTION_BREAK}
    HEREDOC
  end

  def saved_game_prompt
    puts 'Please input a number corresponding to a file listed above: '
  end

  def no_saved_games_prompt
    puts "\nThere are no saved games. Please start a new game.".red
  end

  def game_load_prompt
    puts <<~HEREDOC
    Would you like to start a new game or load a saved game?

    1 - Start a new game
    2 - Load a previously saved game

    HEREDOC
  end

  def game_mode_prompt
    puts <<~HEREDOC
    Please select one of the following game modes:

    1 - Player vs. Player
    2 - Player vs. Computer
    3 - Computer vs. Computer
    HEREDOC
  end

  def warning_prompt_invalid
    puts "\nSorry, that input is invalid".red
  end

  def close_message
    puts "\nThanks for playing!"
  end
end
