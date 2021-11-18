module Displayable
  def restart_message
    puts "\n\nWould you like to play again? Enter (Y/y) to start a new game/load a saved game, or any other key to quit:"
  end

  def close_message
    puts "\nThanks for playing!"
  end

  def save_game_message(filepath)
    "\nYour game has been saved as:  #{filepath.blue}"
  end
end
