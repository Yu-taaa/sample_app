class SessionsController < ApplicationController
  def new
  end
  
  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    #「入力されたメールアドレスを持つユーザーがデータベースに存在する」
    # かつ「入力されたパスワードがそのユーザーのパスワードである」場合のみ、if文がtrueになる
    # user && user.authenticate(params[:session][:password])の省略系
    if @user&.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      log_in @user
      # params[:session][:remember_me]が1の時userを記憶そうでなければuserを忘れるメソッドを呼び出す
      # 以下のif文と同意
      # if params[:session][:remember_me] == '1'
      #   ##Sessionsヘルパーのrememberメソッドを呼び出している
      #   remember(user)
      # else
      #   forget(user)
      # end
      params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
      #「redirect_to user」は、「redirect_to user_url(user)」と同意
      #SessionsHelperで定義したredirect_back_orメソッドを呼び出してリダイレクト先を定義
      redirect_back_or @user
    else
      #flash.now のメッセージはその後リクエストが発生したときに消滅する
      #flash[:hoge] のメッセージはその後リクエストが発生しても消滅しない
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end

# 演習の「cookiesの内容を調べてみて、ログアウト後にはsessionが正常に削除されていることを確認してみましょう。」
# ログアウトしてもcookie自体がなくなるわけではないので、ブラウザの設定画面からのcookie確認ではわかりづらい
# 詳細：http://kzlog.picoaccel.com/post-1001/
# デベロッパーツールで確認すれば「is-logged-in」の項目が削除されることが確認できる
# 詳細：https://gyazo.com/a7b828ba2ff31ab434d77c1921c12d23