module InstanceDisplayable
  def segment_break
    puts "\n#{'-' * 100}"
  end

  def save_game_message(filepath)
    puts "\nYour game has been saved as:  #{filepath.blue}"
  end

  def piece_select_prompt
    puts <<~HEREDOC

    Please input a valid piece position:
    HEREDOC
  end

  def move_select_prompt
    puts <<~HEREDOC

    Please input a valid move position:
    HEREDOC
  end

  def save_quit_message
    puts <<~HEREDOC

    (At any time you may input #{'[SAVE/save]'.green} to save the game, or #{'[QUIT/quit]'.green} to exit the game)
    HEREDOC
  end

  def coordinate_format_message
    puts <<~HEREDOC

    Piece/Move coordinates are of the format #{'[a1]'.blue}/#{'[A1]'.blue} (case insensitive)
    
    HEREDOC
  end
end
