require 'test_helper'
 
class MicropostsControllerTest < ActionDispatch::IntegrationTest
 
  def setup
    @micropost = microposts(:orange)
  end
 
  test "should redirect create when not logged in" do
    # ブロックで渡されたものを呼び出す前後でMicropost.countに違いがない
    assert_no_difference 'Micropost.count' do
      # microposts_pathにparamsハッシュのデータを持たせてpostのリクエスト
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    # login_urlにリダイレクト
    assert_redirected_to login_url
  end
 
  test "should redirect destroy when not logged in" do
    # ブロックで渡されたものを呼び出す前後でMicropost.countに違いがない
    assert_no_difference 'Micropost.count' do
      # micropost_path(@micropost)にdeleteのリクエスト
      delete micropost_path(@micropost)
    end
    # login_urlにリダイレクト
    assert_redirected_to login_url
  end

  # 間違ったユーザーによるマイクロポスト削除に対してテスト
  test "should redirect destroy for wrong micropost" do
    # michaelでログイン
    log_in_as(users(:michael))
    # microposutに代入（fixturesのマイクロポスト）antsを代入
    micropost = microposts(:ants)
    # ブロックで渡されたものを呼び出す前後でMicropost.countに違いがない
    assert_no_difference 'Micropost.count' do
      # micropost_path(micropost)にdeleteのリクエスト
      delete micropost_path(micropost)
    end
    # root_urlにリダイレクト
    assert_redirected_to root_url
  end
end