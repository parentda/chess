require_relative '../lib/game'

describe Game do
  subject(:game) { described_class.new(nil, []) }

  # before do
  #   allow(board).to receive(:populate_grid)
  #   allow(board).to receive(:populate_pieces)
  #   allow(board).to receive(:add_sentinels)
  # end

  describe '#position_to_array' do
    context 'when input is valid' do
      inputs = %w[a8 A8 a1 h8 h1]
      outputs = [[2, 2], [2, 2], [9, 2], [2, 9], [9, 9]]
      it 'returns correct coordinate array' do
        inputs.each_with_index do |input, i|
          expect(game.position_to_array(input)).to eq outputs[i]
        end
      end
    end
  end

  describe '#array_to_position' do
    context 'when input is valid' do
      inputs = [[2, 2], [9, 2], [2, 9], [9, 9]]
      outputs = %w[a8 a1 h8 h1]
      it 'returns correct coordinate array' do
        inputs.each_with_index do |input, i|
          expect(game.array_to_position(input)).to eq outputs[i]
        end
      end
    end
  end
end
