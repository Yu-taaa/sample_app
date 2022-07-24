class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    #「入力されたメールアドレスを持つユーザーがデータベースに存在する」
    # かつ「入力されたパスワードがそのユーザーのパスワードである」場合のみ、if文がtrueになる
    # user && user.authenticate(params[:session][:password])の省略系
    if user&.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
      #「redirect_to user」は、「redirect_to user_url(user)」と同意
      log_in user
      redirect_to user
    else
      #flash.now のメッセージはその後リクエストが発生したときに消滅する
      #flash[:hoge] のメッセージはその後リクエストが発生しても消滅しない
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out
    redirect_to root_url
  end
end

# 演習の「cookiesの内容を調べてみて、ログアウト後にはsessionが正常に削除されていることを確認してみましょう。」
# ログアウトしてもcookie自体がなくなるわけではないので、前後でValueが変わっていることを確認する
# 詳細：http://kzlog.picoaccel.com/post-1001/