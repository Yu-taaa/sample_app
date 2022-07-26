require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      # 管理者であれば削除リンクが表示されない
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin
         # 管理者以外は、削除リンク表示
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # ブロックで渡されたものを呼び出す前後でUser.countが-1
    assert_difference 'User.count', -1 do
      # user_path(@non_admin)にdeleteのリクエスト
      delete user_path(@non_admin)
    end
  end
  
  test "index as non-admin" do
    # @non_adminでログイン
    log_in_as(@non_admin)
    # users_pathにgetのリクエスト
    get users_path
    # 特定のHTMLタグが存在する a 表示テキストは'削除' カウントは0個
    assert_select 'a', text: '削除', count: 0
  end
end