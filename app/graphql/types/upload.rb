class Types::Upload < GraphQL::Schema::Scalar
  description "A file upload"

  def self.coerce_input(input_value, context)
    # Input from multipart form will be an ActionDispatch::Http::UploadedFile
    # or a tempfile-like object
    if input_value.respond_to?(:read) && 
       input_value.respond_to?(:original_filename) && 
       input_value.respond_to?(:content_type)
      input_value
    else
      raise GraphQL::CoercionError, "#{input_value.inspect} is not a valid upload"
    end
  end

  def self.coerce_result(ruby_value, context)
    # This scalar is only used for input, not output
    raise GraphQL::CoercionError, "Upload scalar is only for input"
  end
end