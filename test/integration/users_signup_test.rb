require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  test "invalid signup information" do
    # ユーザー登録ページにアクセス
    get signup_path
    #ブ ロックで渡されたものを呼び出す前後でUser.countに違いがない
    assert_no_difference 'User.count' do
      # users_pathにpostリクエスト → 内容は無効なユーザーデータを持つparams[:user]ハッシュ
      post users_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    # users/newが描写されている（エラーの描写はパーシャルで呼び出している）
    assert_template 'users/new'
    # 描写したページに、id = "error_explanation"を持つdivがある
    assert_select 'div#error_explanation'
    # 描写したページに、class = "alert-dange"を持つdivがある
    assert_select 'div.alert-danger'
  end

  test "valid signup information" do
    get signup_path
    # 第一引数に文字列（'User.count'）を取り、assert_differenceブロック内の処理を実行する直前と、実行した直後のUser.countの値を比較
    # 第二引数の「1」は、 比較した結果の差異（今回の場合は1）を渡す
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    # POSTリクエストを送信した結果を見て、指定されたリダイレクト先に移動するメソッド
    follow_redirect!
    assert_template 'users/show'
    # falseである → flashが空っぽか
    assert_not flash.empty?
    # テストユーザーがサインアップ後にログインしている
    assert is_logged_in?
  end
end