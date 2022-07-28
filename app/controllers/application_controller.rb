class ApplicationController < ActionController::Base
  include SessionsHelper

  private
  # UsersとMicropostsコントローラで必要なので、どちらからも利用できるようにApplicationControllerに記載
  # ログイン済みユーザーかどうか確認
  def logged_in_user
    unless logged_in?
      # SessionsHelperのstore_locationメソッドを呼び出す
      store_location
      flash[:danger] = "Please log in."
      redirect_to login_url
    end
  end
end
