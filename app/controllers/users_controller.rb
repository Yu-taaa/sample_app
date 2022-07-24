class UsersController < ApplicationController

  def show
    @user = User.find(params[:id])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "Welcome to the Sample App!"
      # sessions_helperで定義したlog_inメソッド
      log_in @user
      # edirect_to @userというコードから（Railsエンジニアが）user_url(@user)といったコードを
      # 実行したいということを、Railsが推察してくれた結果になる
      redirect_to @user
    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end