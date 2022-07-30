class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy, :following, :followers]
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy

  def index
    # Usersテーブルからactivated:がtrueのデータをすべて取り出してpaginate(page: params[:page])する
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    # @userが有効ではない場合、root_urlにリダイレクトさせる
    redirect_to root_url and return unless @user.activated?
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
      # flash[:success] = "Welcome to the Sample App!"
      # # sessions_helperで定義したlog_inメソッド
      # log_in @user
      # # edirect_to @userというコードから（Railsエンジニアが）user_url(@user)といったコードを
      # # 実行したいということを、Railsが推察してくれた結果になる
      # redirect_to @user
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      flash[:success] = "Profile updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def following
    @title = "Following"
    # @userにDBから取得したparams[:id]のuserを代入
    @user  = User.find(params[:id])
    # @usersに@user.followingのページネーションを代入
    @users = @user.following.paginate(page: params[:page])
    render 'show_follow'
  end
 
  def followers
    @title = "Followers"
    # @userにDBから取得したparams[:id]のuserを代入
    @user  = User.find(params[:id])
    # @usersに@user.followersのページネーションを代入
    @users = @user.followers.paginate(page: params[:page])
    render 'show_follow'
  end

  private

    def user_params
      # 許可された属性リストにadminを持たせていないので、admin属性を変更できないテストがパスする
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      # リファクタリング前の記述「unless @user == current_user」
      redirect_to(root_url) unless current_user?(@user)
    end

    # 管理者かどうか確認
    def admin_user
      redirect_to(root_url) unless current_user.admin?
    end
end