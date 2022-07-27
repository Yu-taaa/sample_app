require 'test_helper'

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    # userにテストユーザーmichaelを代入
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    # "Account activation"とmail.subjectが等しい
    assert_equal "Account activation", mail.subject
    # [user.email]と mail.toが等しい
    assert_equal [user.email], mail.to
    # ["noreply@example.com"]と mail.fromが等しい
    assert_equal ["noreply@example.com"], mail.from
    # assert_matchメソッドを使って名前、有効化トークン、エスケープ済みメールアドレスがメール本文に含まれているかどうかをテスト
    # user.nameが本文に含まれている
    assert_match user.name,               mail.body.encoded
    # user.activation_tokenが本文に含まれている
    assert_match user.activation_token,   mail.body.encoded
    # 特殊文字をエスケープしたuser.mailが本文に含まれている
    assert_match CGI.escape(user.email),  mail.body.encoded
  end
end