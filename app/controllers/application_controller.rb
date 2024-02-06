class ApplicationController < ActionController::Base
  helper_method :current_player

  before_action :configure_permitted_parameters, if: :devise_controller?

  def current_player
    @current_player ||= Player.find_by(user_id: current_user.id, game_id: @game.id)
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:username])
  end
end
