# https://github.com/jpf/okta-jwks-to-pem/blob/master/jwks_to_pem.py#L50
# https://stackoverflow.com/questions/57217529/how-to-convert-jwk-public-key-to-pem-format-in-c
require "openssl_ext"
require "http/client"
require "json"
require "jwt"
require "simple_retry"
require "tasker"

module JW
  module Public
    struct Key
      include JSON::Serializable
      include JSON::Serializable::Unmapped

      property kid : String
      property kty : Kty

      # RSA - RS256 Algorithm Public Key Props
      property n : String
      property e : String

      # https://tools.ietf.org/html/rfc7518#section-6.1
      # https://tools.ietf.org/html/rfc7518#section-7.4.2
      enum Kty
        # Only supports RSA at the moment
        # EC
        RSA
      end

      def to_pem : String
        self.class.to_pem(self)
      end

      def self.to_pem(jwk : JW::Public::Key) : String
        modulus, exponent = [jwk.n, jwk.e].map do |v|
          bin = Base64.decode(v)
          OpenSSL::BN.from_bin(bin)
        end
        rsa = LibCrypto.rsa_new
        io = IO::Memory.new

        LibCrypto.rsa_set0_key(rsa, modulus, exponent, nil)
        bio = OpenSSL::GETS_BIO.new(io) # also works OpenSSL::BIO.new(io)
        LibCrypto.pem_write_bio_rsa_pub_key(bio, rsa)

        io.to_s
      end
    end

    class KeySets
      getter values : Array(Key)?
      getter uri : String
      getter cache_duration : Time::Span = 24.hours

      def initialize(@uri, @cache_duration = 24.hours)
        jwks = HTTP::Client.get(uri).body

        Tasker.every(cache_duration) do
          @values = Array(Key).from_json(HTTP::Client.get(uri).body, "keys").not_nil!
        end

        @uri = uri
        @values = Array(Key).from_json(jwks, "keys").not_nil!
      end

      def select(kid : String) : Key
        SimpleRetry.try_to(
          max_attempts: 3,
          retry_on: NilAssertionError,
          base_interval: 1.milliseconds,
        ) do |count|
          Log.info { "Retry attempt: #{count}" }
          self.class.new(@uri).values.not_nil!.find(&.kid.== kid).not_nil!
        end
      end
    end
  end

  module Token
    def self.validate_with_jwks_uri(jwt_token : String, jwks_uri : String)
      # JWT Header
      jwt_header = ::JWT.decode(token: jwt_token, verify: false, validate: false)[1]
      raise ArgumentError.new("Typ #{jwt_header["typ"]} of invalid type (should be JWT)") unless jwt_header["typ"] == "JWT"

      # JWT Algo
      algo = ::JWT::Algorithm.parse(jwt_header["alg"].as_s)
      raise ArgumentError.new("Alg #{jwt_header["alg"]} not yet supported (only RS256)") unless algo.as?(::JWT::Algorithm::RS256)

      # JWT Public Key PEM
      jwk = JW::Public::KeySets.new(jwks_uri).select(jwt_header["kid"].as_s)
      jwt_public_key_pem = jwk.to_pem

      ::JWT.decode(token: jwt_token, key: jwt_public_key_pem, algorithm: algo, verify: true, validate: true)
    end
  end
end
