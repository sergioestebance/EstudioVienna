class UserMailer < ActionMailer::Base
  default :from => "viennestudio@gmail.com"
 
  def welcome_email(user)
    @user = user    
    mail(:to => user.email, :subject => "Bienvenida a estudio vienna")
  end
end
