class CreateMicroposts < ActiveRecord::Migration[6.0]
  def change
    create_table :microposts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
    # user_idとcreated_atカラムにインデックスを付与（この↓一行追加)
    add_index :microposts, [:user_id, :created_at]
  end
end
