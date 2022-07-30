require 'test_helper'
 
class RelationshipTest < ActiveSupport::TestCase
 
  def setup
    # @relationshipに新しいrelationshipオブジェクトを代入（michaelがarcherをフォローしている）
    @relationship = Relationship.new(follower_id: users(:michael).id,
                                     followed_id: users(:archer).id)
  end
 
  test "should be valid" do
    # @relationshipが有効である
    assert @relationship.valid?
  end
 
  test "should require a follower_id" do
    # @relationshipのfollower_idにnilを代入
    @relationship.follower_id = nil
    # @relationshipは無効である
    assert_not @relationship.valid?
  end
 
  test "should require a followed_id" do
    # @relationshipのfollowed_idにnilを代入
    @relationship.followed_id = nil
    # @relationshipは無効である
    assert_not @relationship.valid?
  end
end