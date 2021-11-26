module Displayable
  SECTION_BREAK = '-' * 100

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

  def new_game_prompt
    <<~HEREDOC

    Starting new game...
    #{SECTION_BREAK}
    HEREDOC
  end

  def load_game_prompt(filename)
    <<~HEREDOC
    
    Loading #{filename}...
    #{SECTION_BREAK}
    HEREDOC
  end
end
