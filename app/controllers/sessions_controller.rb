class SessionsController < ApplicationController
  def login_form
  end
  skip_before_action :require_login, only: [:login]

  def login
    auth_hash = request.env['omniauth.auth']

    user = User.find_by(uid: auth_hash['uid'], provider: auth_hash['provider'])

    if user
      flash[:status] = :success
      flash[:result_text] = "Successfully logged in as existing user #{user.username}"
    else
      user = User.by_auth_hash(auth_hash)
      if user.save
        flash[:status] = :success
        flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
      else
        flash.now[:status] = :failure
        flash.now[:result_text] = "Could not log in"
        flash.now[:messages] = user.errors.messages
        return render "login_form", status: :bad_request
      end
    end
    session[:user_id] = user.id
    redirect_to root_path
  end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
