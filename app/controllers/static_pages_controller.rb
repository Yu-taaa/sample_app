class StaticPagesController < ApplicationController
  def home
    # もしログインしていたら
    if logged_in?
      # @micropostに　current_userに紐付いたMicropostオブジェクトを代入
      @micropost  = current_user.microposts.build
      # @feed_itemsにcurrent_userに紐付いたフィードのpaginate(page: params[:page])を代入
      @feed_items = current_user.feed.paginate(page: params[:page])
    end
  end

  def help
  end

  def about
  end

  def contact
  end
end
