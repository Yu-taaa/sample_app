require 'test_helper'
 
class RelationshipsControllerTest < ActionDispatch::IntegrationTest
 
  # Relationshipsコントローラのアクションを動かせるのは、ログイン中のユーザーのみ
  # → アクションが呼び出されるときに未ログインユーザーはリダイレクトされるので、Relationshipのカウントは変わらない
  test "create should require logged-in user" do
    # ブロックで渡されたものを呼び出す前後でRelationship.countに違いがない
    assert_no_difference 'Relationship.count' do
      # relationships_pathにPOSTのリクエスト
      post relationships_path
    end
    # login_urlにリダイレクト
    assert_redirected_to login_url
  end
 
  test "destroy should require logged-in user" do
    # ブロックで渡されたものを呼び出す前後でRelationship.countに違いがない
    assert_no_difference 'Relationship.count' do
      # oneのidのrelationship_pathにdeleteのリクエスト
      delete relationship_path(relationships(:one))
    end
    # login_urlにリダイレクト
    assert_redirected_to login_url
  end
end