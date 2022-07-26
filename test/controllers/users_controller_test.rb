require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do
    get users_path
    assert_redirected_to login_url
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user)
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get edit_user_path(@user)
    assert flash.empty?
    # すでにログイン済みのユーザーを対象にしているため、リダイレクトはルート
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # web経由でadmin変更（patch /users/ユーザーid?admin=1） が不可なことを確認する
  test "should not allow the admin attribute to be edited via the web" do
    log_in_as(@other_user)
    # ログインユーザーがadminではないことを確認
    assert_not @other_user.admin?
    # adminではないユーザーにpatchリクエストをし、adminの権限を持たせる
    patch user_path(@other_user), params: {
                                    user: { password:              "password",
                                            password_confirmation: "password",
                                            admin: true } }
    # DBから再度取得した@other_userのadmin?はtrueではない
    assert_not @other_user.reload.admin?
  end

  # ログインしていないユーザーであれば、ログイン画面にリダイレクトされるテスト
  test "should redirect destroy when not logged in" do
    # DELETEリクエストを送信してもブロックで渡されたものを呼び出す前後でUser.countに違いがないことを確認
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_redirected_to login_url
  end

  # ログイン済みではあっても管理者でなければ、ホーム画面にリダイレクトされるテスト
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    # DELETEリクエストを送信してもブロックで渡されたものを呼び出す前後でUser.countに違いがないことを確認
    assert_no_difference 'User.count' do
    # 管理者は削除できないことの確認？
      delete user_path(@user)
    end
    assert_redirected_to root_url
  end

end
