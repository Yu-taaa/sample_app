# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# メインのサンプルユーザーを1人作成する
User.create!(name:  "Example User",
  email: "example@railstutorial.org",
  password:              "foobar",
  password_confirmation: "foobar",
  admin: true,
  activated: true,
  activated_at: Time.zone.now)

# 追加のユーザーをまとめて生成する
99.times do |n|
name  = Faker::Name.name
email = "example-#{n+1}@railstutorial.org"
password = "password"
User.create!(name:  name,
    email: email,
    password:              password,
    password_confirmation: password,
    activated: true,
    activated_at: Time.zone.now)
end

#ユーザーの一部を対象にマイクロポストを生成する
# usersにUserモデルを created_atの順に並び替えて上から（6個を）配列として代入
users = User.order(:created_at).take(6)
50.times do
  content = Faker::Lorem.sentence(word_count: 5)
  users.each { |user| user.microposts.create!(content: content) }
end

# リレーションシップのサンプルを追加
# usersにすべてのユーザーを代入
users = User.all
# userにUserテーブルの1番目のユーザーを代入
user  = users.first
# followingにusersの3番目～51番目を代入
following = users[2..50]
# followersにusersの4番目～41番目を代入
followers = users[3..40]
# followingを順に取り出してブロック内を実行
# 取り出した要素をfollowedに代入 userがfollowedをフォロー
following.each { |followed| user.follow(followed) }
# followersを順に取り出してブロック内を実行
# 取り出した要素をfollowerに代入 followerがユーザーをフォロー
followers.each { |follower| follower.follow(user) }
