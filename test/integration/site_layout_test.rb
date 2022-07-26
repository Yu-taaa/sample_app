require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  #ログインしていない場合のテスト
  test "layout links when not logged in" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count:2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    get contact_path
    assert_select "title", full_title("Contact")
    get about_path
    assert_select "title", full_title("About")
    get help_path
    assert_select "title", full_title("Help")
    get signup_path
    assert_select "title", full_title("Sign up")
  end

  # 以下のテスト直前に@userにusers(:michael)を代入
  def setup
    @user = users(:michael)
  end

  #ログインしている場合のテスト
  test "layout links when logged in" do
    log_in_as(@user)
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count:2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    # ユーザー一覧用のリンク
    assert_select "a[href=?]", users_path
    # マイページ用のリンク
    assert_select "a[href=?]", user_path(@user)
    # 編集用のリンク
    assert_select "a[href=?]", edit_user_path(@user) 
    # ログアウト用のリンク
    assert_select "a[href=?]", logout_path
    get contact_path
    assert_select "title", full_title("Contact")
    get about_path
    assert_select "title", full_title("About")
    get help_path
    assert_select "title", full_title("Help")
   
  end

end