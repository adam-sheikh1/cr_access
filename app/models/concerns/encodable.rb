require 'jwt'

module Encodable
  extend ActiveSupport::Concern

  SECRET_TOKEN = Rails.application.secret_key_base
  ALGORITHM = 'HS256'.freeze
  TTL = 1.year.to_i.freeze

  class_methods do
    def decoded_object(token)
      find decoded_id(token)
    end

    def decoded_id(token)
      JWT.decode(token, SECRET_TOKEN, true, { algorithm: ALGORITHM }).first&.dig('id')
    end

    def decoded_data(token)
      JWT.decode(token, SECRET_TOKEN, true, { algorithm: ALGORITHM }).first
    rescue JWT::ExpiredSignature, JWT::VerificationError, JWT::DecodeError
      nil
    end

    def encoded_token(payload: { id: id })
      payload[:exp] = Time.now.to_i + const_get('TTL')
      JWT.encode(payload, SECRET_TOKEN, ALGORITHM)
    end
  end

  def encoded_token(payload: { id: id })
    payload[:exp] = Time.now.to_i + self.class.const_get('TTL')
    JWT.encode(payload, SECRET_TOKEN, ALGORITHM)
  end
end
