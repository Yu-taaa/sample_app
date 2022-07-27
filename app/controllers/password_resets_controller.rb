class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    # params[:user][:password]がemptyの場合
    if params[:user][:password].empty?
      # @user.errorsに:password, :blankを追加
      # errors.add(:password, :blank)で、パスワードが空だった時に空の文字列に対するデフォルトのメッセージを表示
      @user.errors.add(:password, :blank)
      # editのビューを描画
      render 'edit'
    # 指定された属性の検証がすべて成功した場合@userの更新と保存を続けて同時に行う
    elsif @user.update(user_params)
      # @userとしてログイン
      log_in @user
      # パスワード再設定が成功したらダイジェストをnilに更新しておく
      @user.update_attribute(:reset_digest, nil)
      # 成功のフラッシュメッセージを表示
      flash[:success] = "Password has been reset."
      # ユーザー詳細ページにリダイレクト
      redirect_to @user
    else
      # 無効なパスワードであれば、editのビューを描画
      render 'edit'
    end
  end

  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end

  # @userに代入 → params[:email]のメールアドレスに対応するユーザー
  def get_user
    @user = User.find_by(email: params[:email])
  end

  # 正しいユーザーかどうか確認する
  def valid_user
    # 条件がfalseの場合（@userが存在する かつ @userが有効化されている かつ @userが認証済である）
    unless (@user && @user.activated? &&
            @user.authenticated?(:reset, params[:id]))
      redirect_to root_url
    end
  end

  # 有効期限をチェックする
  def check_expiration
    # password_reset_expired→期限切れかどうかを確認するインスタンスメソッド→詳しくは後程
    if @user.password_reset_expired?
      # 再設定の有効期限切れなflashメッセージ
      flash[:danger] = "Password reset has expired."
      # new_password_reset_urlにリダイレクト
      redirect_to new_password_reset_url
    end
  end
end
