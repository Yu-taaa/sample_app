require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end

  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "     "
    assert_not @user.valid?
    #空白の@user.nameが有効か→falseである←この時成功するテスト
    #現状は空白でもtrueになってしまう為このtestは成功しない
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

  #有効なアドレスの有効性のテスト
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
      #第二引数にエラーメッセージを追加して、どのアドレスでテストが成功しなかったかを特定できるようにしている
      ##{valid_address.inspect} → テストが成功しなかったアドレスが変数展開される
    end
  end
  #バリデーションが設定されていないのでエラーが出ない→有効のテストは成功する

  #無効なアドレスの無効性のテスト
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    #無効なアドレスの@user.emailが有効か→falseである←この時成功するテスト
    end
  end
  #現状、バリデーションが設定されていないのでエラーが出ない→無効のテストは成功しないのでRED
  
  #一意なアドレスではないアドレスの無効性のテスト
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    #dupは、同じ属性を持つデータを複製するためのメソッド
    duplicate_user.email = @user.email.upcase
    # 現在のテストではfoo@bar.comとFOO@BAR.COMは別の物に判断されるが
    # 実際は大文字と小文字で区別はされないため
    # 検証でもメールアドレスの大文字と小文字が区別されないように書く必要がある
    @user.save
    assert_not duplicate_user.valid?
    #一意でないアドレスの@user.emailが有効か→falseである←この時成功するテスト
  end

  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
    #@user.password = @user.password_confirmationに空白を6個代入した時
    #@userは有効か → Falseであると言うテスト
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
    #@user.password = @user.password_confirmationにaを5個代入した時
    #@userは有効か → Falseであると言うテスト
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  test "associated microposts should be destroyed" do
    # @userを保存
    @user.save
    # @userに紐付いたマイクロポストを作成（content:属性に"Lorem ipsum"の値）
    @user.microposts.create!(content: "Lorem ipsum")
    # ブロック内の処理の前後で'Micropost.countが1減っていればtrue
    assert_difference 'Micropost.count', -1 do
      # @userを削除
      @user.destroy
    end
  end

  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    # michaelはarcherをフォローしていない
    assert_not michael.following?(archer)
    # michaelがarcherをフォロー
    michael.follow(archer)
    # michaelはarcherをフォローしている
    assert michael.following?(archer)
    # archerのフォロワーにmichaelが含まれる
    assert archer.followers.include?(michael)
    # michaelのarcherへのフォローをやめる
    michael.unfollow(archer)
    # michaelはarcherをフォローしていない
    assert_not michael.following?(archer)
  end

  # フィードテストの概要
  # 1. フォローしているユーザーのマイクロポストがフィードに含まれている
  # 2. 自分自身のマイクロポストもフィードに含まれている
  # 3. フォローしていないユーザーのマイクロポストがフィードに含まれていない
  test "feed should have the right posts" do
    # michaelはlanaをフォローしている　archerはフォローしていない
    # /sample_app/test/fixtures/relationships.yml参照
    michael = users(:michael)
    archer  = users(:archer)
    lana    = users(:lana)

    # 1. フォローしているユーザーのマイクロポストがフィードに含まれている
    ## lanaのmicropostsを順に取り出してpost_followingに代入
    lana.microposts.each do |post_following|
      # michaelのfeedにpost_followingが含まれている
      assert michael.feed.include?(post_following)
    end

    # 2. 自分自身のマイクロポストもフィードに含まれている
    ## michaelのmicropostsを順に取り出してpost_selfに代入
    michael.microposts.each do |post_self|
      # michaelのfeedにpost_selfが含まれている
      assert michael.feed.include?(post_self)
    end

    # 3. フォローしていないユーザーのマイクロポストがフィードに含まれていない
    ## archerのmicropostsを順に取り出してpost_unfollowedに代入
    archer.microposts.each do |post_unfollowed|
      # michaelのfeedにpost_unfollowedが含まれていない
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
