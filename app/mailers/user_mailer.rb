class UserMailer < ApplicationMailer
  default from: 'notifications@example.com'

  def send_data_as_csv(user_id)
    @user = User.find_by(id: user_id)
    attachments['tickets_data.csv'] = {
      data: @user.documents.last.download,
      mime_type: 'text/csv'
    }
    mail(to: @user.email, subject: 'All Tickets Data Export')
  end

end
