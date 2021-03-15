module TwoFactorAuthShared
  require 'rotp'

  private

  def validate_otp_part(otp)
    validate(user, otp) if otp.match(/\d*/)
  end

  def validate(user, otp)
    totp = ROTP::TOTP.new(Encryption::Service.decrypt(user.encrypted_2fa_secret), issuer: ENV.fetch('SERVICE_NAME'))
    totp.verify(otp)
  end
end
