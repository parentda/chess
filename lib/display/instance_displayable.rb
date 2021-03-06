module InstanceDisplayable
  def segment_break
    puts "\n#{'-' * 100}"
  end

  def save_game_prompt
    puts "\nPlease input a file name to save the game: "
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

  def color_prompt_message(attacking_color)
    color_prompt =
      if attacking_color == :white
        "  WHITE's move  ".black.on_white
      else
        "  BLACK's move  ".white.on_black
      end

    puts <<-HEREDOC

              #{color_prompt}
             
    HEREDOC
  end

  def promotion_prompt
    puts <<~HEREDOC

    Please select one of the following pieces for promotion:

        #{'[1]'.blue} Queen
        #{'[2]'.blue} Rook
        #{'[3]'.blue} Bishop
        #{'[4]'.blue} Knight

    HEREDOC
  end

  def check_message(defending_color)
    color =
      if defending_color == :white
        ' WHITE '.black.on_white
      else
        ' BLACK '.white.on_black
      end

    puts <<~HEREDOC

    #{color} is in CHECK!
    HEREDOC
  end

  def checkmate_message(attacking_color)
    color =
      if attacking_color == :white
        ' WHITE '.black.on_white
      else
        ' BLACK '.white.on_black
      end

    puts <<~HEREDOC

    CHECKMATE! 
    
    #{color} is the winner!
    HEREDOC
  end

  def stalemate_message(defending_color)
    color =
      if defending_color == :white
        ' WHITE '.black.on_white
      else
        ' BLACK '.white.on_black
      end

    puts <<~HEREDOC

    STALEMATE! 
    
    #{color} is not in check, but has no legal moves.

    Therefore, the game is a draw!
    HEREDOC
  end

  def draw_message(turn_limit)
    puts <<~HEREDOC
    
    DRAW!

    The turn limit of #{turn_limit} has elapsed with no winner.
    HEREDOC
  end

  def resign_message(attacking_color)
    if attacking_color == :white
      win_color = ' BLACK '.white.on_black
      lose_color = ' WHITE '.black.on_white
    else
      win_color = ' WHITE '.black.on_white
      lose_color = ' BLACK '.white.on_black
    end

    puts <<~HEREDOC
    
    #{win_color} wins due to #{lose_color} resigning!
    HEREDOC
  end

  def elapsed_turns_message(turns)
    puts <<~HEREDOC
    
    Elapsed Turns: #{turns}
    HEREDOC
  end

  def warning_prompt_invalid
    'Sorry, that input is invalid. Please try again.'.red
  end
end
