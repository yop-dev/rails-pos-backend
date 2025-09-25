class MailerooService
  include HTTParty
  
  base_uri 'https://smtp.maileroo.com'
  
  def initialize
    @api_key = ENV['MAILEROO_API_KEY']
    @from_email = ENV['MAILEROO_FROM_EMAIL'] || ENV['MAILEROO_SMTP_EMAIL'] || 'rails-pos@railspos.maileroo.app'
    @from_name = ENV['MAILEROO_FROM_NAME'] || 'Rails POS'
  end
  
  def send_email(to:, subject:, html_content:, text_content: nil, from_email: nil, from_name: nil)
    return Rails.logger.error("Maileroo API key not configured") unless @api_key
    
    # Use provided from address or fall back to default
    sender_email = from_email || @from_email
    sender_name = from_name || @from_name
    
    payload = {
      to: to,
      from: sender_email,
      from_name: sender_name,
      subject: subject,
      html: html_content
    }
    
    # Add text content if provided
    payload[:text] = text_content if text_content.present?
    
    headers = {
      'X-API-KEY' => @api_key,
      'Content-Type' => 'application/json'
    }
    
    begin
      response = self.class.post('/send', {
        headers: headers,
        body: payload.to_json
      })
      
      if response.success?
        Rails.logger.info("Email sent successfully via Maileroo: #{response.parsed_response}")
        { success: true, response: response.parsed_response }
      else
        Rails.logger.error("Maileroo API error: #{response.code} - #{response.body}")
        { success: false, error: response.body }
      end
    rescue => e
      Rails.logger.error("Maileroo service error: #{e.message}")
      { success: false, error: e.message }
    end
  end
  
  def send_template_email(to:, template_id:, variables: {}, from_email: nil, from_name: nil)
    return Rails.logger.error("Maileroo API key not configured") unless @api_key
    
    # Use provided from address or fall back to default
    sender_email = from_email || @from_email
    sender_name = from_name || @from_name
    
    payload = {
      to: to,
      from: sender_email,
      from_name: sender_name,
      template_id: template_id,
      variables: variables
    }
    
    headers = {
      'X-API-KEY' => @api_key,
      'Content-Type' => 'application/json'
    }
    
    begin
      response = self.class.post('/send', {
        headers: headers,
        body: payload.to_json
      })
      
      if response.success?
        Rails.logger.info("Template email sent successfully via Maileroo: #{response.parsed_response}")
        { success: true, response: response.parsed_response }
      else
        Rails.logger.error("Maileroo API error: #{response.code} - #{response.body}")
        { success: false, error: response.body }
      end
    rescue => e
      Rails.logger.error("Maileroo service error: #{e.message}")
      { success: false, error: e.message }
    end
  end
  
  # Get account status and usage information
  def get_account_info
    return { success: false, error: "API key not configured" } unless @api_key
    
    headers = {
      'X-API-KEY' => @api_key,
      'Content-Type' => 'application/json'
    }
    
    begin
      response = self.class.get('/account', { headers: headers })
      
      if response.success?
        { success: true, account_info: response.parsed_response }
      else
        { success: false, error: response.body }
      end
    rescue => e
      { success: false, error: e.message }
    end
  end
  
  private
  
  def extract_name_from_email(email)
    # Simple name extraction from email - can be enhanced
    email.split('@').first.humanize
  end
end