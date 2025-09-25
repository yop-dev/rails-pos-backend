class GraphqlController < ApplicationController
  include GraphqlMultipart
  
  # If accessing from outside this domain, nullify the session
  # This allows for outside API access while preventing CSRF attacks,
  # but you'll have to authenticate your user separately
  # protect_from_forgery with: :null_session

  def debug
    begin
      # Test basic functionality
      merchant = current_merchant
      render json: { 
        status: "ok", 
        environment: Rails.env,
        database_connected: ActiveRecord::Base.connected?,
        merchant_count: Merchant.count,
        current_merchant: merchant&.name
      }
    rescue => e
      render json: { 
        status: "error", 
        error: e.message,
        backtrace: e.backtrace.first(5)
      }
    end
  end
  
  def test_email
    begin
      # Get test email from params
      test_email = params[:email] || 'desilvajoner95@gmail.com'
      
      # Test Resend configuration
      resend_config = {
        api_key_present: ENV['RESEND_API_KEY'].present?,
        api_key_length: ENV['RESEND_API_KEY']&.length,
        from_email: ENV['RESEND_FROM_EMAIL'],
        from_name: ENV['RESEND_FROM_NAME'],
        delivery_method: Rails.application.config.action_mailer.delivery_method
      }
      
      # Test Resend service directly
      resend_service = ResendService.new
      result = resend_service.send_email(
        to: test_email,
        subject: "Test Email from Rails POS - #{Time.current}",
        html_content: "<h1>Test Email</h1><p>If you receive this, Resend is working correctly!</p><p>Sent at: #{Time.current}</p>",
        text_content: "Test Email - If you receive this, Resend is working correctly! Sent at: #{Time.current}"
      )
      
      render json: {
        status: "ok",
        resend_config: resend_config,
        test_email: test_email,
        send_result: result
      }
    rescue => e
      render json: {
        status: "error",
        error: e.message,
        backtrace: e.backtrace.first(10)
      }
    end
  end
  
  def options
    # Handle CORS preflight request
    head :ok
  end
  
  def execute
    # Try to process multipart request first
    multipart_data = process_multipart_request
    
    if multipart_data
      # Use data from multipart form
      query = multipart_data['query']
      variables = prepare_variables(multipart_data['variables'])
      operation_name = multipart_data['operationName']
    else
      # Use regular params
      variables = prepare_variables(params[:variables])
      query = params[:query]
      operation_name = params[:operationName]
    end
    context = {
      # current_merchant would be set based on authentication
      # For development, we'll just use the first merchant
      current_merchant: current_merchant
    }
    result = RailsPosSchema.execute(query, variables: variables, context: context, operation_name: operation_name)
    render json: result
  rescue StandardError => e
    raise e unless Rails.env.development?
    handle_error_in_development(e)
  end

  private

  def current_merchant
    # In a real application, this would be determined from authentication
    # For assessment purposes, we'll return the first merchant or create one
    Merchant.first || Merchant.create!(
      name: "Demo Merchant",
      email: "merchant@example.com",
      phone: "09171234567",
      address: "123 Demo Street, Manila"
    )
  end

  # Handle variables in form data, JSON body, or a blank value
  def prepare_variables(variables_param)
    case variables_param
    when String
      if variables_param.present?
        JSON.parse(variables_param) || {}
      else
        {}
      end
    when Hash
      variables_param
    when ActionController::Parameters
      variables_param.to_unsafe_hash # GraphQL-Ruby will validate name and type of incoming variables.
    when nil
      {}
    else
      raise ArgumentError, "Unexpected parameter: #{variables_param}"
    end
  end

  def handle_error_in_development(e)
    logger.error e.message
    logger.error e.backtrace.join("\n")

    render json: { errors: [{ message: e.message, backtrace: e.backtrace }], data: {} }, status: 500
  end
end