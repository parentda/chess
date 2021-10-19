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
end
