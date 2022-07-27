class User < ApplicationRecord
  # 実際にDBにはない、仮の属性の読み取りと書き込みをするときによく使う ※DB関係なく使うこともある
  # remember_token属性をUserクラスに定義
  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  
  # Userクラスのインスタンのsaveの直前に現在のユーザーのemailにemailを小文字にしたものを代入
 
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
  # bcryptパスワードを作成する（新しくレコードが追加されたときだけに適用されるメソッド）
  has_secure_password
  # allow_nil: true で空のパスワードを有効にしているが、
  # has_secure_passwordではオブジェクト生成時に存在性を検証するようになっているため、空のパスワード（nil）が新規ユーザー登録時に有効になることはない
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

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

  # ランダムなトークンを返す
  # Userのインスタンスは不要なので、クラスメソッドとして作成する
  def User.new_token
    # コンソールで確認可
    # A–Z、a–z、0–9、"-"、"_"のいずれかの文字（64種類）からなる長さ22のランダムな文字列を返すメソッド
    SecureRandom.urlsafe_base64
  end

   # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    #（selfを付けるとクラス変数になる→この場合User.remember_tokenと同意）
    # これにより、ユーザーのremember_token属性に要素を代入
    self.remember_token = User.new_token
    # update_attributeメソッドは検証を素通りする
    # パスワード確認ができないので、検証を素通りさせる必要がある
    # validationを無視して更新（:remember_digest属性にハッシュ化したremember_tokenを設定）
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # ユーザーのログイン情報を破棄する
  def forget
    update_attribute(:remember_digest, nil)
  end

  # トークンがダイジェストと一致したらtrueを返す
  # def authenticated?(remember_token)
  #   digest = self.send("remember_digest")
  #   return false if digest.nil?
  #   BCrypt::Password.new(digest).is_password?(remember_token)
  # end
  # ↑これが↓こうなる
  # 2番目の引数tokenの名前を変更して一般化し、他の認証でも使えるようにしている
  # def authenticated?(attribute, token)
  #   digest = self.send("#{attribute}_digest")
  #   return false if digest.nil?
  #   BCrypt::Password.new(digest).is_password?(token)
  # end
  # モデル内にあるのでselfは省略できるため↑これが↓こうなる
  # user.authenticated?(:remember, remember_token)で以下のメソッドが呼び出せる
  # attributeの引数に与えられた内容によって、呼び出すメソッドを変更している
  # authenticated?(:remember, '')で呼び出すと、remember_digestメソッドを呼び、
  # authenticated?(:activation, '')で呼び出すと、activation_digestメソッドを呼び出し
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end

  # アカウントを有効にする
  def activate
     # userのactivatedの値をtrueに、activated_atの値を現在時刻で上書き
     update_columns(activated: true, activated_at: Time.zone.now)
  end

  # 有効化用のメールを送信する
  def send_activation_email
    # UserMailerの引数に@userを定義したaccount_activationメソッドで今すぐメールを送信
    # selfは、@userのこと
    UserMailer.account_activation(self).deliver_now
  end
  
  # パスワード再設定の属性を設定する
  def create_reset_digest
   # （呼び出し先で考えると）@userのreset_tokenに代入→User.new_token
   self.reset_token = User.new_token
   # 指定のカラムを指定の値に、DBに直接上書き保存
   update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
  end

  # パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  # パスワード再設定の期限が切れている場合はtrueを返す
  def password_reset_expired?
    # パスワード再設定メールの送信時刻が、現在時刻より2時間より前（早い）の場合
    reset_sent_at < 2.hours.ago
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      # Userモデルの中ではself.email = self.email.downcaseの右側のselfは省略できる
      # self.email = email.downcaseはさらに省略可
      self.email.downcase!
    end

    # 有効化トークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token  = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
