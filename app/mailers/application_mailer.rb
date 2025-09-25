class ApplicationMailer < ActionMailer::Base
  # Use Resend from address, fallback to default
  default from: -> { ENV['RESEND_FROM_EMAIL'] || 'noreply@yopn8n.cfd' }
  layout "mailer"
  
  private
  
  def mail_with_sender(merchant_email: nil, **options)
    # Check if we should use Resend API instead of SMTP
    if use_resend?
      send_via_resend(merchant_email: merchant_email, **options)
    else
      # Allow overriding the from address per merchant if provided for SMTP
      if merchant_email.present? && Rails.application.config.action_mailer.delivery_method == :smtp
        options[:from] = merchant_email
      end
      mail(options)
    end
  end
  
  def send_via_resend(merchant_email: nil, **options)
    resend = ResendService.new
    
    # Render the email template
    template_name = options[:template] || "#{controller_path}/#{action_name}"
    html_content = render_to_string(template: template_name, layout: 'mailer')
    text_content = nil # You can add text rendering if needed
    
    # Use merchant email as from address if provided, otherwise use default
    # Note: For Resend, the from email must be from a verified domain
    from_email = ENV['RESEND_FROM_EMAIL'] || 'noreply@yopn8n.cfd'
    from_name = ENV['RESEND_FROM_NAME'] || 'Rails POS'
    
    result = resend.send_email(
      to: options[:to],
      subject: options[:subject],
      html_content: html_content,
      text_content: text_content,
      from_email: from_email,
      from_name: from_name
    )
    
    unless result[:success]
      Rails.logger.error("Failed to send email via Resend: #{result[:error]}")
      # Optionally raise an error or handle the failure
      raise "Email delivery failed: #{result[:error]}" if Rails.env.production?
    end
    
    result
  end
  
  def use_resend?
    # Use Resend if API key is configured and delivery method is set to :resend
    ENV['RESEND_API_KEY'].present? && Rails.application.config.action_mailer.delivery_method == :resend
  end
end
