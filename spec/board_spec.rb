require_relative '../lib/board/board'

describe Board do
  subject(:board) { described_class.new }

  # before do
  #   allow(board).to receive(:populate_grid)
  #   allow(board).to receive(:populate_pieces)
  #   allow(board).to receive(:add_sentinels)
  # end

  describe '#valid_input?' do
    context 'when given a valid input' do
      inputs = %w[a1 A1 h8 H8]
      it 'returns true' do
        inputs.each { |input| expect(board.valid_input?(input)).to be true }
      end
    end

    context 'when given an invalid input' do
      inputs = %w[a0 A9 i8 I8 a11 Aa1 1a 12a aa 11]
      it 'returns false' do
        inputs.each { |input| expect(board.valid_input?(input)).to be false }
      end
    end
  end

  describe '#convert_input' do
    context 'when input is valid' do
      inputs = %w[a8 A8 a1 h8 h1]
      outputs = [[2, 2], [2, 2], [9, 2], [2, 9], [9, 9]]
      it 'returns correct coordinate array' do
        inputs.each_with_index do |input, i|
          expect(board.convert_input(input)).to eq outputs[i]
        end
      end
    end
  end

  describe '#attacked_by?' do
    row = 6
    col = 5
    defending_color = :white
    attacking_color = :black
    attackers = [
      [Queen, [6, 3]],
      [Rook, [6, 2]],
      [Knight, [5, 3]],
      [Bishop, [4, 3]],
      [Pawn, [5, 6]]
    ]

    before do
      board.positions[row][col].occupant = King.new(defending_color)
      attackers.each do |piece|
        board.positions[piece[1][0]][piece[1][1]].occupant =
          piece[0].new(attacking_color)
      end
    end

    context 'when piece is within range of attack' do
      it 'returns true' do
        [Queen, Knight, Bishop, Pawn].each do |piece|
          expect(
            board.attacked_by?(
              [row, col],
              piece,
              attacking_color,
              defending_color
            )
          ).to be true
        end
      end
    end

    context 'when piece is out of range of attack' do
      it 'returns false' do
        [King, Rook].each do |piece|
          expect(
            board.attacked_by?(
              [row, col],
              piece,
              attacking_color,
              defending_color
            )
          ).to be false
        end
      end
    end
  end

  describe '#check?' do
    defending_color = :white
    attacking_color = :black

    context 'when white King is attacked by a black Knight' do
      attacker = [[Knight, [7, 7]]]

      before do
        attacker.each do |piece|
          board.positions[piece[1][0]][piece[1][1]].occupant =
            piece[0].new(attacking_color)
        end
      end
      it 'returns true' do
        expect(board.check?(attacking_color, defending_color)).to be true
      end
    end

    context 'when black King is attacked by a white Pawn' do
      attacker = [[Pawn, [3, 5]]]

      before do
        attacker.each do |piece|
          board.positions[piece[1][0]][piece[1][1]].occupant =
            piece[0].new(defending_color)
        end
      end
      it 'returns true' do
        expect(board.check?(defending_color, attacking_color)).to be true
      end
    end

    context 'when white King is attacked by a black Queen' do
      attacker = [[Queen, [5, 2]]]

      before do
        board.positions[8][5].clear
        attacker.each do |piece|
          board.positions[piece[1][0]][piece[1][1]].occupant =
            piece[0].new(attacking_color)
        end
      end
      it 'returns true' do
        expect(board.check?(attacking_color, defending_color)).to be true
      end
    end

    context 'when white King is attacked by a black Pawn' do
      attacker = [[Pawn, [8, 5]]]

      before do
        attacker.each do |piece|
          new_piece = piece[0].new(attacking_color)
          board.positions[piece[1][0]][piece[1][1]].occupant = new_piece
        end
      end
      it 'returns true' do
        expect(board.check?(attacking_color, defending_color)).to be true
      end
    end

    context 'when game starts' do
      it 'returns false' do
        expect(board.check?(attacking_color, defending_color)).to be false
      end
    end
  end

  describe '#legal_moves' do
    context 'when white Bishop is blocking an attack on the white King from the black Queen' do
      it 'returns only positions that keep the white King out of check' do
        white_pawn = board.positions[8][5].occupant
        white_bishop = board.positions[9][4].occupant
        black_queen = board.positions[2][5].occupant
        board.make_move(white_pawn, [8, 5], [6, 5])
        board.make_move(white_bishop, [9, 4], [8, 5])
        board.make_move(black_queen, [2, 5], [5, 2])
        true_legal_positions = [[7, 4], [6, 3], [5, 2]]
        pseudo_legal_positions = board.pseudo_legal_moves([8, 5])
        expect(
          board.legal_moves([8, 5], pseudo_legal_positions)
        ).to eq true_legal_positions
      end
    end

    context 'when white King is currently in check from the black Queen' do
      it 'white Queen can only move to block or capture the black Queen' do
        white_pawn = board.positions[8][6].occupant
        white_queen = board.positions[9][5].occupant
        black_queen = board.positions[2][5].occupant
        board.make_move(white_pawn, [8, 6], [6, 4])
        board.make_move(white_queen, [9, 5], [7, 9])
        board.make_move(black_queen, [2, 5], [4, 6])
        true_legal_positions = [[4, 6], [7, 6]]
        pseudo_legal_positions = board.pseudo_legal_moves([7, 9])
        expect(
          board.legal_moves([7, 9], pseudo_legal_positions)
        ).to eq true_legal_positions
      end
    end

    context 'when white King is currently safe, but taking en passant would put the King in check' do
      it 'does not allow the en passant to occur' do
        white_pawn = board.positions[8][6].occupant
        white_king = board.positions[9][6].occupant
        black_pawn = board.positions[3][6].occupant
        black_queen = board.positions[2][5].occupant
        board.make_move(white_pawn, [8, 6], [5, 5])
        board.make_move(white_king, [9, 6], [5, 2])
        board.make_move(black_queen, [2, 5], [5, 9])
        board.make_move(black_pawn, [3, 6], [5, 6])
        board.moves_list
        true_legal_positions = [[4, 5]]
        pseudo_legal_positions = board.pseudo_legal_moves([5, 5])
        expect(
          board.legal_moves([5, 5], pseudo_legal_positions)
        ).to eq true_legal_positions
      end
    end

    context 'when white King is not under attack and will not be by the movement of the white Bishop' do
      it 'returns all possible positions for the white Bishop' do
        white_pawn = board.positions[8][5].occupant
        white_bishop = board.positions[9][4].occupant
        board.make_move(white_pawn, [8, 5], [6, 5])
        board.make_move(white_bishop, [9, 4], [8, 5])
        true_legal_positions = [
          [7, 4],
          [6, 3],
          [5, 2],
          [9, 4],
          [7, 6],
          [6, 7],
          [5, 8],
          [4, 9]
        ].sort
        pseudo_legal_positions = board.pseudo_legal_moves([8, 5])
        expect(
          board.legal_moves([8, 5], pseudo_legal_positions).sort
        ).to eq true_legal_positions
      end
    end
  end

  describe '#castle_availability' do
    let(:coords) { [9, 6] }
    let(:piece) { board.positions[9][6].occupant }

    context 'when both castle options are available' do
      it 'returns a list of two moves' do
        empty_spaces = [[9, 3], [9, 4], [9, 5], [9, 7], [9, 8]]
        empty_spaces.each do |coords|
          board.positions[coords[0]][coords[1]].clear
        end
        legal_moves = board.castle_availability(coords, piece)

        expect(legal_moves.length).to eq(2)
      end
    end

    context 'when one castle option is available and the other is blocked by a piece' do
      it 'returns a list of one move' do
        empty_spaces = [[9, 4], [9, 5], [9, 7], [9, 8]]
        empty_spaces.each do |coords|
          board.positions[coords[0]][coords[1]].clear
        end
        legal_moves = board.castle_availability(coords, piece)

        expect(legal_moves.length).to eq(1)
      end
    end

    context 'when one castle option is available and the other is attacked by an enemy piece' do
      it 'returns a list of two moves' do
        coords = [2, 6]
        piece = board.positions[coords[0]][coords[1]].occupant
        empty_spaces = [[2, 3], [2, 4], [2, 5], [2, 7], [2, 8]]
        empty_spaces.each do |coords|
          board.positions[coords[0]][coords[1]].clear
        end
        board.positions[4][8].occupant = Knight.new(:white)
        legal_moves = board.castle_availability(coords, piece)

        expect(legal_moves.length).to eq(1)
      end
    end

    context 'when one castle option is available while the other rook has already moved' do
      it 'returns a list of one moves' do
        empty_spaces = [[9, 3], [9, 4], [9, 5], [9, 7], [9, 8]]
        empty_spaces.each do |coords|
          board.positions[coords[0]][coords[1]].clear
        end
        rook = board.positions[9][2].occupant
        rook_pos = [9, 2]
        board.make_move(rook, rook_pos, [9, 3])
        board.make_move(rook, [9, 3], rook_pos)
        legal_moves = board.castle_availability(coords, piece)

        expect(legal_moves.length).to eq(1)
      end
    end

    context 'when neither castle option is available because the King is in check' do
      it 'returns an empty list' do
        empty_spaces = [[9, 3], [9, 4], [9, 5], [9, 7], [9, 8]]
        empty_spaces.each do |coords|
          board.positions[coords[0]][coords[1]].clear
        end
        board.positions[7][7].occupant = Knight.new(:black)
        legal_moves = board.castle_availability(coords, piece)

        expect(legal_moves.length).to eq(0)
      end
    end

    context 'when neither castle option is available because the King has moved' do
      it 'returns an empty list' do
        empty_spaces = [[9, 3], [9, 4], [9, 5], [9, 7], [9, 8]]
        empty_spaces.each do |coords|
          board.positions[coords[0]][coords[1]].clear
        end
        board.make_move(piece, coords, [9, 5])
        board.make_move(piece, [9, 5], coords)
        legal_moves = board.castle_availability(coords, piece)

        expect(legal_moves.length).to eq(0)
      end
    end
  end

  describe '#en_passant_availability' do
  end

  describe '#pawn_capture_availability' do
  end

  describe '#pawn_double_step_availability' do
  end
end
