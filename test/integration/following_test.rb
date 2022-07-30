require 'test_helper'
 
class FollowingTest < ActionDispatch::IntegrationTest
  # setupでmichaelを@userに代入ログイン済とする
  def setup
    @user = users(:michael)
    @other = users(:archer)
    log_in_as(@user)
  end
 
  # フォロー数が正しいのか確認
  test "following page" do
    # /users/@userのid/followingにgetのリクエスト
    get following_user_path(@user)
    # falseである → @user.followingがempty
    assert_not @user.following.empty?
    # trueである → @user.followingのcountを文字列にしたものが本文に一致
    assert_match @user.following.count.to_s, response.body
    # @user.followingを順に取り出してuserに代入
    @user.following.each do |user|
      # 特定のHTMLタグが存在する→ a href = "/users/userのid"
      assert_select "a[href=?]", user_path(user)
    end
  end
 
  # フォロワー数が正しいのか確認
  test "followers page" do
    # /users/@userのid/followersにgetのリクエスト
    get followers_user_path(@user)
    # falseである → @user.followersがempty
    assert_not @user.followers.empty?
    # trueである → @user.followersのcountを文字列にしたものが本文に一致
    assert_match @user.followers.count.to_s, response.body
    # @user.followersを順に取り出してuserに代入
    @user.followers.each do |user|
      # 特定のHTMLタグが存在する→ a href = "/users/userのid"
      assert_select "a[href=?]", user_path(user)
    end
  end

  # フォローができているか確認（通常の通信）
  test "should follow a user the standard way" do
    # ブロック内の処理の前後で@user.following.countが1増える
    assert_difference '@user.following.count', 1 do
      # relationships_pathにpostのリクエスト（@other をフォローする）
      post relationships_path, params: { followed_id: @other.id }
    end
  end
 
   # フォローができているか確認（Ajax通信）
  test "should follow a user with Ajax" do
    # ブロック内の処理の前後で@user.following.countが1増える
    assert_difference '@user.following.count', 1 do
      # relationships_pathにAjaxでpostのリクエスト（@other をフォローする）
      post relationships_path, xhr: true, params: { followed_id: @other.id }
    end
  end
 
  # フォロー解除ができているか確認（通常の通信）
  test "should unfollow a user the standard way" do
    # @userが@otherをフォロー
    @user.follow(@other)
    # relationshipに代入 → DBの@userのactive_relationshipsからfollowed_id:が@other.idと一致するデータ
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # ブロック内の処理の前後で@user.following.countが-1
    assert_difference '@user.following.count', -1 do
      # relationship_pathにdeleteのリクエスト（relationshipを削除する）
      delete relationship_path(relationship)
    end
  end
 
   # フォロー解除ができているか確認（Ajax通信）
  test "should unfollow a user with Ajax" do
    # @userが@otherをフォロー
    @user.follow(@other)
    # relationshipに代入 → DBの@userのactive_relationshipsからfollowed_id:が@other.idと一致するデータ
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # ブロック内の処理の前後で@user.following.countが-1
    assert_difference '@user.following.count', -1 do
      # relationship_pathAjaxでにdeleteのリクエスト（relationshipを削除する）
      delete relationship_path(relationship), xhr: true
    end
  end
end