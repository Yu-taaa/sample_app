class ApplicationMailer < ActionMailer::Base
  # 送信元のメールアドレスを設定
  default from: "noreply@example.com"
  layout 'mailer'
end
