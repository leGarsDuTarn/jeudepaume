class ApplicationController < ActionController::Base
  include Pundit::Authorization

  # Empêche les accès non autorisés
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  private

  def user_not_authorized
    flash[:alert] = "Vous n’êtes pas autorisé à effectuer cette action."
    redirect_to(request.referer || root_path)
  end
end
