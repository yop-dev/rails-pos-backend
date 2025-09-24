class CloudinaryService
  def self.upload_product_photo(file, merchant_id)
    return { public_id: nil, url: nil } unless file

    begin
      # Handle different file input types
      file_path = if file.respond_to?(:tempfile)
        # ActionDispatch::Http::UploadedFile
        file.tempfile.path
      elsif file.respond_to?(:path)
        # File or Tempfile
        file.path
      else
        # Assume it's already a path or file-like object
        file
      end

      result = Cloudinary::Uploader.upload(
        file_path,
        folder: "merchants/#{merchant_id}/products",
        resource_type: "auto",
        transformation: [
          { width: 800, height: 800, crop: "limit" },
          { quality: "auto", fetch_format: "auto" }
        ]
      )

      {
        public_id: result["public_id"],
        url: result["secure_url"]
      }
    rescue => e
      Rails.logger.error "Cloudinary upload failed: #{e.message}"
      { public_id: nil, url: nil, error: e.message }
    end
  end

  def self.delete_asset(public_id)
    return false unless public_id.present?

    begin
      result = Cloudinary::Uploader.destroy(public_id)
      result["result"] == "ok"
    rescue => e
      Rails.logger.error "Cloudinary delete failed: #{e.message}"
      false
    end
  end
end