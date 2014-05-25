class SorceryMailer < ActionMailer::Base
  
  default from: "m@fueledbymarv.in", from_name: "Marvin Qian"
  
  def activation_needed_email(user)
    @user = user
    @url  = "#{ENV['FBM_ROOT_URL']}/#/activate/#{user.activation_token}"
    mail(to: user.email,
         to_name: user.email,
         subject: "Welcome!")
  end
  
  def activation_success_email(user)
    @user = user
    @url  = "#{ENV['FBM_ROOT_URL']}"
    mail(to: user.email,
         to_name: user.email,
         subject: "Your account is active!")
  end
  
  def reset_password_email(user)
    @user = user
    @url  = "#{ENV['FBM_ROOT_URL']}/#/reset/#{user.reset_password_token}"
    mail(to: user.email,
         to_name: user.email,
         subject: "Your password reset request.")
  end
end
