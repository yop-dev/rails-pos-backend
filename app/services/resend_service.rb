class ResendService
  def initialize
    @api_key = ENV['RESEND_API_KEY']
    raise "Resend API key not configured" unless @api_key.present?
    
    @from_email = ENV['RESEND_FROM_EMAIL'] || 'noreply@yopn8n.cfd'
    @from_name = ENV['RESEND_FROM_NAME'] || 'Rails POS'
  end
  
  def send_email(to:, subject:, html_content:, text_content: nil, from_email: nil, from_name: nil)
    return Rails.logger.error("Resend API key not configured") unless @api_key
    
    # Use provided from address or fall back to default
    sender_email = from_email || @from_email
    sender_name = from_name || @from_name
    from_address = "#{sender_name} <#{sender_email}>"
    
    params = {
      from: from_address,
      to: [to],
      subject: subject,
      html: html_content
    }
    
    # Add text content if provided
    params[:text] = text_content if text_content.present?
    
    begin
      # Use the working Pattern 4: Direct class method
      Resend.api_key = @api_key
      response = Resend::Emails.send(params)
      
      Rails.logger.info("Email sent successfully via Resend: #{response}")
      { success: true, response: response }
    rescue => e
      Rails.logger.error("Resend service error: #{e.message}")
      { success: false, error: e.message }
    end
  end
  
  # Get account information (if needed)
  def get_account_info
    return { success: false, error: "API key not configured" } unless @api_key
    
    begin
      # Test the API key by setting it globally
      Resend.api_key = @api_key
      { success: true, message: "Resend API key is configured and working" }
    rescue => e
      { success: false, error: e.message }
    end
  end
end
