class ApplicationController < ActionController::Base
  def check_login
    unless user_signed_in?
      redirect_to new_user_session_url
      flash[:alert] = "Please login"
    end
  end
end
