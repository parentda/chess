require_relative 'game'

def play_game
  loop do
    game = Game.create_game
    game.play
    break Game.close unless Game.restart
  end
end

play_game
