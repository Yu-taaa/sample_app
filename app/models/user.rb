class User < ApplicationRecord
  has_many :microposts, dependent: :destroy
  
  # Userモデルと:active_relationshipsはhas_many (1対多) の関係性がある
  # クラスはRelationship、外部キーはfollower_id、（ユーザーが削除された時）紐づいているactive_relationshipsも削除される
  has_many :active_relationships,  class_name:  "Relationship",
                                   foreign_key: "follower_id",
                                   dependent:   :destroy
  
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy

  # Userとfollowingはactive_relationshipsを介して多対多の関係を持っている
  # 本来は、has_many :followeds, through: :active_relationships としたい
  #「followeds」というシンボル名を「followed」という単数形に変えて、 relationshipsテーブルのfollowed_idを使って対象のユーザーを取得する働きを持つ
  #「user.followeds」は英語として不適切なので「user.following」という名前を使いたい
  # :sourceパラメーター を使うと明示的に「following配列の元はfollowed_idの集合である」と伝えられる
  has_many :following, through: :active_relationships, source: :followed
  # :followers属性の場合、Railsが「followers」を単数形にして自動的に外部キーfollower_idを探してくれるからsourceは省略してもいい
  has_many :followers, through: :passive_relationships, source: :follower

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
  
  # 試作feedの定義
  # 完全な実装は次章の「ユーザーをフォローする」を参照
  def feed
    Micropost.where("user_id = ?", id)
  end

  # ユーザーをフォローする
  def follow(other_user)
    # followingの最後にother_userを追加
    following << other_user
  end
 
  # ユーザーをフォロー解除する
  def unfollow(other_user)
    # active_relationshipsからfollowed_idがother_user.idのデータを取得して削除
    active_relationships.find_by(followed_id: other_user.id).destroy
  end

  # ユーザーのステータスフィードを返す
  def feed
    # Micropostsテーブルから取得条件 → user_idに、フォローしているユーザーのidか現在のユーザーのidを持つもの
    # IN を使うとidの集合の内容（今回で言えば、following_idsの配列）を条件に指定できる
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # ↑ だと、following_idsでフォローしている全てのユーザーを発行し、その上で条件にかけているので再度、SQLを発行している？から非効率
  
    # DBでサブセレクトを利用して、following_idsをSQLに置き換えるとこうなる
    # SELECT * FROM microposts
    # WHERE user_id IN (SELECT followed_id FROM relationships
    #               WHERE  follower_id = :user_id)
    #   OR user_id = :user_id
    # IN （「:user_id == 1 のユーザー（1は例）がフォローしているユーザーすべてを選択する」）の内包ロジック（↑の（）の部分）を
    # 既存のSQLにネストさせることで、RailsではなくDB側に処理を一任させれる→効率的
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    
    # サブセレクトを利用して内包させたSQLの条件が以下になる
    Micropost.where("user_id IN (#{following_ids})
                     OR user_id = :user_id", user_id: id)
  end
 
  # 現在のユーザーがフォローしてたらtrueを返す
  def following?(other_user)
    # followingにother_userが含まれているか
    following.include?(other_user)
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
