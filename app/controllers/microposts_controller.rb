class MicropostsController < ApplicationController
  # 直前にlogged_in_userメソッド（ApplicationController）を実行 :create, :destroyアクションにのみ適用
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy
  
  def create
    # @micropostにログイン中のユーザーに紐付いた新しいマイクロポストオブジェクトを返す（引数 micropost_params）
    @micropost = current_user.microposts.build(micropost_params)
    # Active Storage APIから画像追加できるようにattachメソッドが提供されてる
    @micropost.image.attach(params[:micropost][:image])
    #  @micropostを保存できれば
    if @micropost.save
      # 成功のフラッシュメッセージを表示
      flash[:success] = t('.micropost_created')
      # ルートURLにリダイレクト
      redirect_to root_url
    # 保存できなければ
    else
      # 空の投稿をしてしまうと、_feed.html.erbの @feed_items.anyで「undefined method `any?' for nil:NilClass」に
      # になってしまうので、既に投稿されたデータを入れるか、[]を代入しておく
      @feed_items = current_user.feed.paginate(page: params[:page])
      # static_pages/homeを描画
      render 'static_pages/home'
    end
  end
 
  def destroy
    @micropost.destroy
    flash[:success] = t('.micropost_deleted')
    # リダイレクト（request.referrerで返される）一つ前のURL もしくはroot_url
    # DELETEリクエストが発行されたページに戻すことができる
    # 元に戻すURLが見つからなかった場合でも（例えばテストではnilが返ってくることもあり）root_urlに戻る
    # ↓に変換可能 redirect_to request.referrer || root_url
    # fallback_locationオプションで例外エラーが発生した際のリダイレクト先にroot_urlを指定
    redirect_back(fallback_location: root_url)
  end
  
  private
 
    def micropost_params
      # micropost属性必須 content属性のみ変更を許可
      params.require(:micropost).permit(:content, :image)
    end

    def correct_user
      # @microposutに代入 current_userのmicropostsからparams[:id]を持つmicropostを取得
      @micropost = current_user.microposts.find_by(id: params[:id])
      # root_urlにredirect もし@micropostがnilなら
      redirect_to root_url if @micropost.nil?
    end
end