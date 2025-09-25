class ApplicationMailer < ActionMailer::Base
  # Use environment variable for from address, fallback to Gmail username
  default from: -> { ENV['GMAIL_FROM_ADDRESS'] || ENV['GMAIL_USERNAME'] || 'noreply@example.com' }
  layout "mailer"
  
  private
  
  def mail_with_sender(merchant_email: nil, **options)
    # Allow overriding the from address per merchant if provided
    if merchant_email.present? && Rails.application.config.action_mailer.delivery_method == :smtp
      options[:from] = merchant_email
    end
    
    mail(options)
  end
end
