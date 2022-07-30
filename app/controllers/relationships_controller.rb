class RelationshipsController < ApplicationController
  # 直前にlogged_in_userメソッド（ApplicationController）を実行
  before_action :logged_in_user
 
  def create
    # userに代入 params[:followed_id]のデータをUserテーブルから取得
    @user = User.find(params[:followed_id])
    # current_userでuserをフォローする
    current_user.follow(@user)
    # リクエストの種類によってブロック内のいずれか1行が実行される
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
 
  def destroy
    # userに代入 Relationshipテーブルからfollowedカラムの内容がparams[:id]のデータを取得
    @user = Relationship.find(params[:id]).followed
    # current_userでuserをアンフォローする
    current_user.unfollow(@user)
    # リクエストの種類によってブロック内のいずれか1行が実行される
    respond_to do |format|
      format.html { redirect_to @user }
      format.js
    end
  end
end