module ClassDisplayable
  def segment_break
    puts "\n#{'-' * 100}"
  end

  def intro_message
    puts <<~HEREDOC

    Welcome to #{'CHESS'.blue}!
    
    If you do not know the rules of chess, please familiarize yourself with them at the following link:

      http://www.chessvariants.org/d.chess/chess.html
    
    Each turn requires two separate inputs:

        - Coordinates of the piece to move
        - Coordinates of a legal move for the selected piece

    HEREDOC
  end

  def restart_message
    puts "\n\nWould you like to play again? Enter (Y/y) to start a new game/load a saved game, or any other key to quit:"
  end

  def display_saved_games(hash)
    output = ''
    hash.each do |key, value|
      output += "\n    #{'['.blue}#{key.to_s.blue}#{']'.blue}  #{value}"
    end

    puts <<~HEREDOC

    Saved Games:
    #{output}
    HEREDOC
  end

  def new_game_message
    puts <<~HEREDOC

    Starting new game...
    HEREDOC

    sleep(1)
  end

  def load_game_message(filename)
    puts <<~HEREDOC

    Loading #{filename}...
    HEREDOC

    sleep(1)
  end

  def saved_game_prompt
    puts 'Please input a number corresponding to a file listed above: '
  end

  def no_saved_games_prompt
    puts "\nThere are no saved games. Please start a new game.".yellow
  end

  def game_load_prompt
    puts <<~HEREDOC

    To begin, would you like to start a new game or load a saved game?

        #{'[1]'.green} Start a new game
        #{'[2]'.green} Load a saved game

    HEREDOC
  end

  def game_mode_prompt
    puts <<~HEREDOC

    Please select one of the following game modes:

        #{'[1]'.blue} Player vs. Player
        #{'[2]'.blue} Player vs. Computer
        #{'[3]'.blue} Computer vs. Computer

    HEREDOC
  end

  def select_color_prompt
    puts <<~HEREDOC

    Please select the player color:

        #{'[1]'.red} White
        #{'[2]'.red} Black
    
    HEREDOC
  end

  def warning_prompt_invalid
    'Sorry, that input is invalid. Please try again.'.red
  end

  def close_message
    puts "\nThanks for playing!"
  end
end
