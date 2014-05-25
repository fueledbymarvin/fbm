require 'mandrill'

class MandrillDelivery

  def m
    @m ||= Mandrill::API.new ENV['FBM_MANDRILL_KEY']
  end

  def initialize(mail)
  end

  def deliver!(mail)
    message = {
      from_name: mail['from_name'],
      from_email: mail['from'],
      subject: mail['subject'],
      to: [{
             email: mail['to'],
             name: mail['to_name']
           }],
      html: mail.body
    }

    sending = m.messages.send message
    Rails.logger.info sending
  end
end

