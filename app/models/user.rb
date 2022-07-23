class User < ApplicationRecord
  #Userクラスのインスタンのsaveの直前に現在のユーザーのemailにemailを小文字にしたものを代入
  #Userモデルの中ではself.email = self.email.downcaseの右側のselfは省略できる
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  #定数VALID_EMAIL_REGEXにメールアドレスのフォーマットを検証するための正規表現を代入
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  # uniqueness:ヘルパーのオプション
  # 一意性制約で大文字小文字を区別するかどうかを指定するもの
  # uniqueness:値が一意であるかの検証にcase_sensitive: false（大文字と小文字を区別しない）というオプション
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }
end
#メールアドレスのフォーマットに関するバリデーションを設定したことにより
#メールアドレスの無効性のテストも成功する