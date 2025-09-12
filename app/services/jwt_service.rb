require 'jwt'
require 'active_support/core_ext/numeric/time'
require 'active_support/hash_with_indifferent_access'

class JwtService
  def self.secret_key
    ENV['JWT_SECRET_KEY']
  end

  def self.encode(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, secret_key)
  end

  def self.decode(token)
    return nil unless token

    body = JWT.decode(token, secret_key)[0]
    HashWithIndifferentAccess.new body
  rescue JWT::ExpiredSignature, JWT::VerificationError
    nil
  end
end