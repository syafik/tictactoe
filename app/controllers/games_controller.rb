class GamesController < ApplicationController
  before_action :authenticate_user!
  before_action :find_game, except: [:index, :new, :create]

  def index
    @games = Game.all.includes(:user)
  end

  def new
    @game = current_user.games.new
    @game.players.build(user_id: current_user.id, sign: 'X')
  end

  def create
    @game = current_user.games.new(game_params)
    if @game.save
      redirect_to game_path(@game)
    else
      render turbo_stream: turbo_stream.replace('error_container_id', partial: 'shared/error_messages', locals: { object: @game })
    end
  end

  def show
    redirect_to games_path if @game.nil?
  end

  def join; end

  def play
    @game.with_lock do
      if @game.valid_for_join?(current_user)
        @game.players.create(user_id: current_user.id, sign: 'O')
        @game.ready!
        redirect_to game_path(@game)
      else
        render turbo_stream: turbo_stream.replace('error_container_id', partial: 'shared/error_messages', locals: { object: @game })
      end
    end
  end

  def start
    @game.with_lock do
      @game.turn_player_id = @game.players.first.id
      @game.running!
    end
    redirect_to game_path(@game)
  end

  def move
    @row = params[:row]
    @col = params[:col]
    @valid = @game.your_turn?(current_player) && @game.valid_move?(row: @row, col: @col)
  end

  def submit_move
    @row = move_params[:row]
    @col = move_params[:col]
    @game.update_board_and_change_turn(current_player, @row, @col)
    redirect_to game_path(@game)
  end

  def reset_board
    return redirect_to game_path(@game), notice: 'can not reset' unless current_user.owner?(@game)

    @game.reset
    redirect_to game_path(@game)
  end

  def destroy
    redirect_to games_path and return if @game.nil?

    @game.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@game) }
      format.html { redirect_to games_path, notice: 'Record was successfully destroyed.' }
    end
  end

  private

  def find_game
    @game = Game.includes(players: :user).find_by(id: params[:id])
  end

  def game_params
    params.require(:game).permit(:user_id, :rowcols, players_attributes: [:user_id, :name, :sign])
  end

  # def join_params
  #   params.require(:join).permit(:user_id, :name, :sign)
  # end

  def move_params
    params.require(:move).permit(:row, :col)
  end
end
