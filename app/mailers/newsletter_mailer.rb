class NewsletterMailer < ActionMailer::Base
  default from: "support@halfpastnow.com"

  # Subject can be set in your I18n file at config/locales/en.yml
  # with the following lookup:
  #
  #   en.newsletter_mailer.weekly.subject
  #
  def weekly(user)
    puts "sending newsletter email..."
    @user = user
    @url  = "http://halfpastnow.com/login"
    mail(:to => user.email, :subject => "This week in half past now.")
  end
end
