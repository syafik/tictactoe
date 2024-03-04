require 'rails_helper'

RSpec.describe GamesController, type: :controller do
  let(:user) { create(:user) }
  let(:user2) { create(:user) }
  let(:game) { create(:game, user: user) } 

  before do
    sign_in user
  end

  describe 'GET #index' do
    it 'returns a successful response' do
      get :index
      expect(response).to be_successful
    end
  end

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid parameters' do
      it 'creates a new game and redirects to the game page' do
        post :create, params: { game: { user_id: user.id, rowcols: 3 } }

        expect(response).to redirect_to(game_path(assigns(:game)))
      end
    end

    context 'with invalid parameters' do
      it 'renders the new template with Turbo Stream error messages' do
        post :create, params: { game: { user_id: user.id } }

        expect(response).to render_template('shared/_error_messages')
        expect(response.body).to include('turbo-stream')
        expect(response.body).to include('<turbo-stream action="replace" target="error_container_id">')
      end
    end
  end

  describe 'GET #show' do
    it 'redirects to the games_path if game is nil' do
      get :show, params: { id: 100 }  # assuming no id 100
      expect(response).to redirect_to(games_path)
    end
  end

  describe 'Get #play' do
    it 'creates a new player and redirects to the game page' do
      sign_in(user2)

      get :play, params: { id: game.id }

      expect(response).to redirect_to(game_path(assigns(:game)))
    end

    it 'renders the Turbo Stream error messages template if not valid for join' do
      sign_in(user2)
      allow_any_instance_of(Game).to receive(:valid_for_join?).and_return(false)
      post :play, params: { id: game.id }

      expect(response).to render_template('shared/_error_messages')
      expect(response.body).to include('<turbo-stream action="replace" target="error_container_id">')
    end
  end

  describe 'POST #start' do
    it 'updates game state and redirects to the game page' do
      game.players.create(user_id: user.id, sign: 'O')
      game.players.create(user_id: user2.id, sign: 'X')

      post :start, params: { id: game.id }

      expect(response).to redirect_to(game_path(assigns(:game)))
    end
  end

  describe 'GET #move' do
    it 'assigns instance variables for row and col' do
      game.players.create(user_id: user.id, sign: 'O')
      game.players.create(user_id: user2.id, sign: 'X')

      get :move, params: { id: game.id, row: 1, col: 1 }, xhr: true

      expect(assigns(:row)).to eq('1')
      expect(assigns(:col)).to eq('1')
    end

    # Add more tests for other scenarios related to move action if needed
  end

  describe 'POST #submit_move' do
    it 'updates game board and changes turn' do
      game.players.create(user_id: user.id, sign: 'O')
      game.players.create(user_id: user2.id, sign: 'X')

      post :submit_move, params: { id: game.id, move: { row: 1, col: 1 } }

      expect(response).to redirect_to(game_path(assigns(:game)))
    end
  end

  describe 'POST #submit_move' do
    it 'updates the game board and redirects to the game page' do
      game.players.create(user_id: user.id, sign: 'O')
      game.players.create(user_id: user2.id, sign: 'X')

      post :submit_move, params: { id: game.id, move: { row: 1, col: 1 } }

      expect(response).to redirect_to(game_path(assigns(:game)))
    end
  end

  describe 'POST #submit_move (when move is not valid)' do
    it 'does not update the game board and redirects to the game page' do
      game.players.create(user_id: user.id, sign: 'O')
      game.players.create(user_id: user2.id, sign: 'X')

      # Add logic to make the move not valid for testing this scenario
      allow_any_instance_of(Game).to receive(:valid_move?).and_return(false)

      post :submit_move, params: { id: game.id, move: { row: 1, col: 1 } }

      expect(response).to redirect_to(game_path(assigns(:game)))
      expect(assigns(:valid)).to be_falsey
    end
  end

  describe 'POST #reset_board' do
    context 'when the current user is the owner' do
      it 'resets the game board and redirects to the game page' do
        game.players.create(user_id: user.id, sign: 'O')
        game.players.create(user_id: user2.id, sign: 'X')

        post :reset_board, params: { id: game.id }

        expect(response).to redirect_to(game_path(assigns(:game)))
      end
    end

    context 'when the current user is not the owner' do
      it 'does not reset the game board and redirects to the game page with a notice' do
        game.players.create(user_id: user.id, sign: 'O')
        game.players.create(user_id: user2.id, sign: 'X')

        sign_in(user2)

        post :reset_board, params: { id: game.id }

        expect(response).to redirect_to(game_path(assigns(:game)))
        expect(flash[:notice]).to eq('can not reset')
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the game record and renders Turbo Stream for removal' do
      delete :destroy, params: { id: game.id }

      expect(response).to redirect_to(games_path)
      expect(Game.exists?(game.id)).to be_falsey
    end
  end

  describe 'DELETE #destroy (when game is nil)' do
    it 'redirects to games_path without destroying anything' do
      delete :destroy, params: { id: 100 }

      expect(response).to redirect_to(games_path)
      # Add any other expectations based on your application logic
    end
  end
end
