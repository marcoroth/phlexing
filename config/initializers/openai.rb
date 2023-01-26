# frozen_string_literal: true

Ruby::OpenAI.configure do |config|
  config.access_token = Rails.application.credentials[:openai_key]
end
