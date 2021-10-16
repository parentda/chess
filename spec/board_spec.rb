require_relative '../lib/board/board'

describe Board do
  subject(:board) { described_class.new }
  before do
    allow(board).to receive(:populate_grid)
    allow(board).to receive(:populate_pieces)
    allow(board).to receive(:add_sentinels)
  end

  describe '#valid_input?' do
    context 'when given a valid input' do
      it 'returns true' do
        expect(board.valid_input?('a1')).to be true
        expect(board.valid_input?('A1')).to be true
        expect(board.valid_input?('h8')).to be true
        expect(board.valid_input?('H8')).to be true
      end
    end

    context 'when given an invalid input' do
      it 'returns false' do
        expect(board.valid_input?('a0')).to be false
        expect(board.valid_input?('A9')).to be false
        expect(board.valid_input?('i8')).to be false
        expect(board.valid_input?('I8')).to be false
        expect(board.valid_input?('a11')).to be false
        expect(board.valid_input?('Aa1')).to be false
        expect(board.valid_input?('1a')).to be false
        expect(board.valid_input?('12a')).to be false
        expect(board.valid_input?('aa')).to be false
        expect(board.valid_input?('11')).to be false
      end
    end
  end
end
