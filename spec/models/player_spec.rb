require 'rails_helper'

RSpec.describe Player, type: :model do
  let(:user) { create(:user) }
  let(:game) { create(:game, user: user) }

  describe 'validations' do
    # it { should validate_presence_of(:name) }
  end

  describe 'associations' do
    it { should belong_to(:user) }
    it { should belong_to(:game) }
  end

  describe 'basic functionality' do
    let(:player) { create(:player, user: user, game: game) }

    it 'is valid with valid attributes' do
      expect(player).to be_valid
    end

    it 'belongs to a user' do
      expect(player.user).to eq(user)
    end

    it 'belongs to a game' do
      expect(player.game).to eq(game)
    end
  end
end
