# Cloudinary configuration
# Environment variables expected:
# - CLOUDINARY_URL (complete URL with credentials) OR
# - CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, CLOUDINARY_API_SECRET

if Rails.env.development? || Rails.env.test?
  # For development, you can set these in .env file or use the full CLOUDINARY_URL
  # Example CLOUDINARY_URL: cloudinary://api_key:api_secret@cloud_name
  
  # Fallback configuration for development if no credentials are set
  unless ENV['CLOUDINARY_URL'] || (ENV['CLOUDINARY_CLOUD_NAME'] && ENV['CLOUDINARY_API_KEY'] && ENV['CLOUDINARY_API_SECRET'])
    Rails.logger.warn "Cloudinary not configured. File uploads will not work."
    Rails.logger.warn "Set CLOUDINARY_URL or CLOUDINARY_CLOUD_NAME/CLOUDINARY_API_KEY/CLOUDINARY_API_SECRET environment variables."
  end
else
  # Production should always have Cloudinary configured
  if ENV['CLOUDINARY_URL'].blank? && (ENV['CLOUDINARY_CLOUD_NAME'].blank? || ENV['CLOUDINARY_API_KEY'].blank? || ENV['CLOUDINARY_API_SECRET'].blank?)
    raise "Cloudinary configuration missing. Set CLOUDINARY_URL or individual credentials."
  end
end

# Configure Cloudinary if credentials are available
if ENV['CLOUDINARY_URL'] || (ENV['CLOUDINARY_CLOUD_NAME'] && ENV['CLOUDINARY_API_KEY'] && ENV['CLOUDINARY_API_SECRET'])
  Cloudinary.config do |config|
    if ENV['CLOUDINARY_URL']
      # Parse full URL
      uri = URI.parse(ENV['CLOUDINARY_URL'])
      config.cloud_name = uri.host
      config.api_key = uri.user
      config.api_secret = uri.password
    else
      # Use individual credentials
      config.cloud_name = ENV['CLOUDINARY_CLOUD_NAME']
      config.api_key = ENV['CLOUDINARY_API_KEY']
      config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
    
    config.secure = true
    config.cdn_subdomain = true
  end
end