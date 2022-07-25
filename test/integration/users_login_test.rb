require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    # usersはfixtureのファイル名users.ymlを表し、
    # :michaelというシンボルはファイル内のユーザーを参照するためのキー
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email: "", password: "" } }
    assert_template 'sessions/new'
    assert_not flash.empty?
    # フラッシュメッセージが追加されているか？ → 追加されていなければfalse
    # つまり、フラッシュメッセージが追加されることを確認している
    get root_path
    assert flash.empty?
    # フラッシュメッセージが追加されているか？ → 追加されていなければtrue
    # つまり、フラッシュメッセージが追加されていないことを確認している
  end

  test "login with valid email/invalid password" do
    get login_path
    assert_template 'sessions/new'
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid" } }
    #falseである → テストユーザーがログインしている
    assert_not is_logged_in?
    assert_template 'sessions/new'
    assert_not flash.empty?
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    # テストユーザーがログインしている(test_helper.rbのis_logged_in?メソッド)
    assert is_logged_in?
    # ユーザー詳細画面にリダイレクトされる
    assert_redirected_to @user
    # 実際にリダイレクト先に移動
    follow_redirect!
    # users/showが描写される
    assert_template 'users/show'
    # login_pathへのリンクの数が0である
    assert_select "a[href=?]", login_path, count: 0
    # logout_pathへのリンクがある
    assert_select "a[href=?]", logout_path
    # user_path(@user)へのリンクがある
    assert_select "a[href=?]", user_path(@user)

    # logout_pathへdeleteのリクエスト
    delete logout_path
    # falseである  →テストユーザーがログインしている
    assert_not is_logged_in?
    # ルートURLへリダイレクト
    assert_redirected_to root_url
    # 2番目のウィンドウでログアウトをクリックするユーザーをシミュレートする
    delete logout_path
    # 実際にリダイレクト先に移動
    follow_redirect!
    # login_pathへのリンクがある
    assert_select "a[href=?]", login_path
    # logout_pathへのリンクが0である
    assert_select "a[href=?]", logout_path,      count: 0
    # user_path(@user)へのリンクが0である
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  # チェックボックスがオンになっている時のテスト
  test "login with remembering" do
    # cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    # cookies['remember_token']はempty?ではない
    assert_not_empty cookies[:remember_token]
    # cookiesのremember_tokenと@userのremember_tokenが等しいときにtrue
    # assigns(:user)で、Sessionsコントローラの@userにアクセスできる
    # 疑問：なぜ、Sessionsコントローラのcreateアクションの@userと特定できる？？
    # 仮説：このテスト自体がSessionsコントローラのcreateアクションでの出来事だから？
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

   # チェックボックスがオフになっている時のテスト
  test "login without remembering" do
    # cookieを保存してログイン
    log_in_as(@user, remember_me: '1')
    delete logout_path
    # cookieを削除してログイン
    log_in_as(@user, remember_me: '0')
    # cookies['remember_token']はempty?である
    assert_empty cookies[:remember_token]
  end
end
