module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    #sessionメソッドで作成された一時cookiesは、ブラウザを閉じた瞬間に有効期限が終了する
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続的にする
  def remember(user)
    user.remember
    cookies.permanent.encrypted[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # 現在ログイン中のユーザーを返す（いる場合）
  def current_user
    #「（ユーザーIDにユーザーIDのセッションを代入した結果）ユーザーIDのセッションが存在すれば」
    if (user_id = session[:user_id])
      @current_user ||= User.find_by(id: user_id)
    #「（ユーザーIDにcookiesの暗号化されたuser_idを代入した結果）暗号化されたuser_idが存在すれば」
    elsif (user_id = cookies.encrypted[:user_id])
      user = User.find_by(id: user_id)
       # もし、「userが存在する」かつ「cookieが持つトークンがダイジェストと一致する」場合
      if user && user.authenticated?(cookies[:remember_token])
        log_in user
        @current_user = user
      end
    end
    # 下のコードだと①、②の文でsessionとcookiesメソッドをそれぞれ2回ずつ使っていて冗長
    # # もしsessionにuser_idが有れば
    # ① if session[:user_id]
    #   # @current_user = @current_user || User.find_by(id: session[:user_id])と同意
    #   # 項を左から順に評価し、最初にtrueになった時点で処理を終える
    #   @current_user ||= User.find_by(id: session[:user_id])
    #   # session[:user_id]が存在しなければ、cookies.encrypted[:user_id]の値を取って
    # ② elsif cookies.encrypted[:user_id]
    #   # userにcookiesから取り出したidの値がUser.idと一致するユーザーを代入
    #   user = User.find_by(id: cookies.encrypted[:user_id])
    #   # もし、「userが存在する」かつ「cookieが持つトークンがダイジェストと一致する」場合
    #   if user && user.authenticated?(cookies[:remember_token])
    #     # 渡されたユーザーでログイン
    #     log_in user
    #     # @current_userにuserを代入
    #     @current_user = user
    #   end
    # end
  end

  # ユーザーがログインしていればtrue、その他ならfalseを返す
  def logged_in?
    !current_user.nil?
  end

  # 永続的セッションを破棄する
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # 現在のユーザーをログアウトする
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end
end

# log_outメソッド→forger(user)メソッド→user.forgetメソッドの呼び出し
