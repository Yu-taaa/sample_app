class CreateRelationships < ActiveRecord::Migration[6.0]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    # データベースでの検索頻度が多いので、インデックスを追加する
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    # あるユーザーが同じユーザーを2回以上フォローすることを防ぐため一意にする
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
