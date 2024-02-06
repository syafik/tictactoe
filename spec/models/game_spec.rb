require 'rails_helper'

RSpec.describe Game, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:game) { create(:game, user: user) }

  describe 'validations' do
    subject { game }
    it { should validate_presence_of(:rowcols) }
    it { should validate_numericality_of(:rowcols).is_greater_than_or_equal_to(3).is_less_than_or_equal_to(10).with_message('must be a whole number between 3 and 10') }
  end

  describe 'associations' do
    subject { game }
    it { should belong_to(:user) }
    it { should belong_to(:turn_player).class_name('Player').optional(true) }
    it { should belong_to(:winner_player).class_name('Player').optional(true) }
    it { should have_many(:players) }
  end

  describe 'methods' do
    let(:game) { create(:game, user: user) }
    let!(:player1) { create(:player, user: user, game: game, sign: 'X') }
    let!(:player2) { create(:player, user: other_user, game: game, sign: '0') }

    it 'should have default status waiting_other_player' do
      expect(game.status).to eq('waiting_other_player')
    end

    context 'join' do
      it 'valid_for_join? true' do
        expect(game.valid_for_join?(other_user)).to be_truthy
      end

      it 'valid_for_join? false' do
        game.ready!
        expect(game.valid_for_join?(other_user)).to be_falsey
      end
    end

    it 'your_turn?' do
      game.update(turn_player: player1)
      expect(game.your_turn?(player1)).to be_truthy
    end

    it 'valid_move?' do
      game.update(status: :running, turn_player: player1)
      expect(game.valid_move?(row: 1, col: 1)).to be_truthy
    end

    it 'invalid move' do
      game.update(status: :running, turn_player: player1, board: [[88, 0, 0],[0, 0, 0],[0, 0, 0]])
      expect(game.valid_move?(row: 0, col: 0)).to be_falsey
    end

    it 'create_default_board' do
      game.create_default_board
      expect(game.board.flatten.all?(0)).to be_truthy
    end

    it 'reseted' do
      game.update(status: :running, turn_player: player1, board: [[88, 0, 0], [0, 0, 0], [0, 0, 0]])
      game.reset
      expect(game.turn_player).to eq(player1)
      expect(game.board.flatten.all?(0)).to be_truthy
      expect(game.winner_player_id).to be_nil
    end

    it 'update_board_and_change_turn' do
      game.update(status: :running, turn_player: player1)
      game.update_board_and_change_turn(player1, 0, 0)
      expect(game.turn_player).to eq(player2)
    end

    it 'next_player_turn' do
      expect(game.next_player_turn(player1)).to eq(player2)
    end

    it 'check_winner' do
      game.update(status: :running)
      game.update_board_and_change_turn(player1, 0, 0)
      game.update_board_and_change_turn(player2, 1, 1)
      game.update_board_and_change_turn(player1, 0, 1)
      game.update_board_and_change_turn(player2, 1, 2)
      game.update_board_and_change_turn(player1, 0, 2)

      expect(game.check_winner).to be_truthy
    end
  end
end
