require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    # 事前ログインのためのメソッド呼び出し
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name:  "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }

    assert_template 'users/edit'
    assert_select "div.alert", "The form contains 4 errors."
  end

   # successful editのテストを編集していく
   # 未ログインユーザーが編集ページにアクセスしようとしていたなら、ユーザーがログインした後にはその編集ページにリダイレクトされるようにするテスト
   # 1.編集ページにアクセス
   # 2.ログイン
   # 3.プロフィールページではなく編集ページにリダイレクト
  test "successful edit with friendly forwarding" do
    # 編集ページにアクセスするため、edit_user_path(@user)にgetのリクエスト
    get edit_user_path(@user)
    # session[:forwarding_url]とedit_user_url(@user)が等しい時にtrue
    assert_equal session[:forwarding_url], edit_user_url(@user)
    # @userとしてログイン
    log_in_as(@user)
    # edit用のテンプレートはリダイレクトで描画されるので下記一文は削除
    # assert_template 'users/edit'
    # session[:forwarding_url]がnilの時true
    assert_nil session[:forwarding_url]
    # @userのユーザー編集ページにリダイレクトされる
    assert_redirected_to edit_user_url(@user)
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    # falseである → flashが空っぽであるか
    assert_not flash.empty?
    # リダイレクトされている →@user（プロフィールページ）
    assert_redirected_to @user
    # @user（プロフィールページ）を再読み込み
    @user.reload
    # name（入力値）と@user.name（DBの値）が等しい
    assert_equal name,  @user.name
    # email（入力値）と@user.email（DBの値）が等しい
    assert_equal email, @user.email
  end
end