module InstanceDisplayable
  def restart_message
    puts "\n\nWould you like to play again? Enter (Y/y) to start a new game/load a saved game, or any other key to quit:"
  end

  def save_game_message(filepath)
    puts "\nYour game has been saved as:  #{filepath.blue}"
  end

  def select_color_prompt
    puts <<~HEREDOC
    Please select the player color:

    1 - White
    2 - Black
    HEREDOC
  end

  def piece_select_prompt; end

  def move_select_prompt; end
end