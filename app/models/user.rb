class User < ApplicationRecord
  # Userクラスのインスタンのsaveの直前に現在のユーザーのemailにemailを小文字にしたものを代入
  # Userモデルの中ではself.email = self.email.downcaseの右側のselfは省略できる
  before_save { email.downcase! }
  validates :name,  presence: true, length: { maximum: 50 }
  
  # 定数VALID_EMAIL_REGEXにメールアドレスのフォーマットを検証するための正規表現を代入
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  
  # uniqueness:ヘルパーのオプション
  # 一意性制約で大文字小文字を区別するかどうかを指定するもの
  # uniqueness:値が一意であるかの検証にcase_sensitive: false（大文字と小文字を区別しない）というオプション
  # メールアドレスのフォーマットに関するバリデーションを設定したことにより
  # メールアドレスの無効性のテストも成功する
  validates :email, presence: true, length: { maximum: 255 },
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  # bcryptパスワードを作成する
  has_secure_password
  validates :password, presence: true, length: { minimum: 6 }

  # 渡された文字列のハッシュ値を返す
  # fixture向け（テスト用データ）のdigestメソッドを追加
  # Userクラスのdigestメソッド（クラスメソッドの定義）self.メソッド名
  def User.digest(string)
    # テスト中は最小で本番環境ではしっかりなコストパラメータの計算的な事
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    # secure_passwordのソースコードのパスワード生成部分
    # string→ハッシュ化する文字列 cost→ハッシュを算出するための計算コスト                                              
    BCrypt::Password.create(string, cost: cost)
  end
end
