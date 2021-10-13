class Knight
  @@movement = [2, 1, -1, -2]

  def moves
    @@movement.permutation(2).filter { |pair| pair[0].abs != pair[1].abs }
  end
end
