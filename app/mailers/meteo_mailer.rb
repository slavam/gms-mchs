class MeteoMailer < ApplicationMailer
  default from: "DSinoptik@Gidromet.MCHS"
  
  def welcome_email(user)
    @user = user
    @url  = 'http://www.gmail.com'
    # attachments['bulletin.pdf'] = File.read('app/assets/pdf_folder/Bulletin_12.pdf')
    mail(to: "mwm1955@gmail.com", subject: 'Welcome to My Awesome Site')
  end
end
