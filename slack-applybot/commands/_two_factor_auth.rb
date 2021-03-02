module TwoFactorAuth
  require 'rotp'

  private

  def validate(user, otp)
    totp = ROTP::TOTP.new(Encryption::Service.decrypt(user.encrypted_2fa_secret), issuer: ENV.fetch('SERVICE_NAME'))
    totp.verify(otp)
  end
end
