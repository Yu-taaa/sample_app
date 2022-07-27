class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    #「!user.activated?」userがactivatedではないという条件を追加している
    # 既に有効になっているユーザーを誤って再度有効化しないために必要
    # 攻撃者がユーザーの有効化リンクを後から盗みだしてクリックするだけで、本当のユーザーとしてログインできてしまうため
    # 生成された有効化トークンは、認証URLに組み込まれているため params[:id]で取得できる
    #「userが存在する」かつ「userがactivatedではない」かつ「有効化トークンとparams[:id](activation_token)が持つ有効化ダイジェストが一致」した場合
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
