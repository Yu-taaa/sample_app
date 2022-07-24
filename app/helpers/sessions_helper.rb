module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    #sessionメソッドで作成された一時cookiesは、ブラウザを閉じた瞬間に有効期限が終了する
    session[:user_id] = user.id
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    #もしsessionにuser_idが有れば
    if session[:user_id]
      # @current_user = @current_user || User.find_by(id: session[:user_id])と同意
      # 項を左から順に評価し、最初にtrueになった時点で処理を終える
      @current_user ||= User.find_by(id: session[:user_id])
    end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 現在のユーザーをログアウトする
  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
