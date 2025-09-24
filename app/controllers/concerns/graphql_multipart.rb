module GraphqlMultipart
  extend ActiveSupport::Concern

  private

  def process_multipart_request
    # Check if this is a multipart request
    if request.content_type&.start_with?('multipart/form-data')
      operations = params[:operations]
      map = params[:map]

      # Parse operations if it's a string
      if operations.is_a?(String)
        operations = JSON.parse(operations)
      end

      # Parse map if it's a string  
      if map.is_a?(String)
        map = JSON.parse(map)
      end

      # Process file uploads if map exists
      if map.present?
        map.each do |file_key, paths|
          uploaded_file = params[file_key]
          next unless uploaded_file

          # Apply the uploaded file to each specified path in the operations
          paths.each do |path|
            set_nested_value(operations, path, uploaded_file)
          end
        end
      end

      # Return the modified operations
      operations
    else
      # Not a multipart request, return nil
      nil
    end
  end

  def set_nested_value(hash, path, value)
    keys = path.split('.')
    target = hash

    # Navigate to the parent of the final key
    keys[0..-2].each do |key|
      if key.match?(/\A\d+\z/)
        # Array index
        target = target[key.to_i]
      else
        # Hash key
        target = target[key] ||= {}
      end
    end

    # Set the final value
    final_key = keys.last
    if final_key.match?(/\A\d+\z/)
      target[final_key.to_i] = value
    else
      target[final_key] = value
    end
  end
end