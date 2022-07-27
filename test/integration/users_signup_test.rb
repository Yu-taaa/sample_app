require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    # 配信されるメッセージを初期化（配列deliveriesを空にする）
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    # ユーザー登録ページにアクセス
    get signup_path
    # ブロックで渡されたものを呼び出す前後でUser.countに違いがない
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

  # valid signup informationテストに機能追加
  test "valid signup information with account activation" do
    # ユーザー登録ページにアクセス
    get signup_path
    # 有効化されたユーザーが追加されたか確認
    ## 第一引数に文字列（'User.count'）を取り、assert_differenceブロック内の処理を実行する直前と、実行した直後のUser.countの値を比較
    ## 第二引数の「1」は、 比較した結果の差異（今回の場合は1）を渡す
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
   # 配信メールの数が1つになったことを確認
   ## 引数の値が等しい１とActionMailer::Base.deliveriesに格納された配列の数
   assert_equal 1, ActionMailer::Base.deliveries.size

   # 有効化されていないユーザーの挙動確認
   ## userに@userを代入（通常統合テストからはアクセスできないattr_accessorで定義した属性の値にもアクセスできるようになる）
   user = assigns(:user)
   ## userが有効ではない（userがまだこの時点では有効化されていないことを確認）
   assert_not user.activated?
   ## 有効化していない状態でログインしてみる
   log_in_as(user)
   ## テストユーザーがログインしていない
   assert_not is_logged_in?

   # 有効化できないパターンとできるパターン（その後の挙動含め）の確認
   ## 有効化トークンが不正な場合
   get edit_account_activation_path("invalid token", email: user.email)
   ## テストユーザーがログインしていない
   assert_not is_logged_in?

   ## トークンは正しいがメールアドレスが無効な場合
   get edit_account_activation_path(user.activation_token, email: 'wrong')
   ## テストユーザーがログインしていない
   assert_not is_logged_in?

   ## 有効化トークンが正しい場合（この時点でようやく有効化できる条件をパスしている）
   get edit_account_activation_path(user.activation_token, email: user.email)
   ## userの値を再取得すると有効化している
   assert user.reload.activated?
   ## 実際にリダイレクト先に移動
   follow_redirect!
   ## sers/showが描写される
   assert_template 'users/show'
   ## テストユーザーがログインしている
   assert is_logged_in?
  end
end