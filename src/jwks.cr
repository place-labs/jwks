# https://github.com/jpf/okta-jwks-to-pem/blob/master/jwks_to_pem.py#L50
# https://stackoverflow.com/questions/57217529/how-to-convert-jwk-public-key-to-pem-format-in-c
require "openssl_ext"
require "http/client"
require "json"
require "jwt"
require "simple_retry"
require "tasker"

# # Algorithms:
# https://w3c.github.io/webcrypto/
# https://docs.microsoft.com/en-us/azure/key-vault/keys/about-keys-details
# https://www.w3.org/2012/webcrypto/wiki/KeyWrap_Proposal
module JWK
  abstract class Key
    include JSON::Serializable
    include JSON::Serializable::Unmapped

    use_json_discriminator "kty", {"RSA" => RSA, "EC" => EC, "oct" => OCT}

    # # Parameters
    property kty : String # req
    property use : String?
    property key_ops : Array(String)?
    property alg : String?
    property kid : String?
    property x5u : String? # : URI
    property x5c : Array(String)?
    property x5t : String?
    @[JSON::Field(key: "x5t#S256")]
    property x5t_S256 : String?
    property ext : Bool?
    property oth : NamedTuple(d: String?, r: String?, t: String?)?
  end

  # # Rivest–Shamir–Adleman
  # 2408 4098 Encrypt Sign
  class RSA < Key
    # PUB
    property n : String
    property e : String

    # PRIV
    property d : String?
    property p : String?
    property q : String?
    property dp : String?
    property dq : String?
    property qi : String?

    def to_pem : String
      RSA.to_pem(self)
    end

    def self.to_pem(jwk : JWK::RSA) : String
      modulus, exponent = [jwk.n.not_nil!, jwk.e.not_nil!].map do |v|
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

  # # Elliptic-curve
  # crv: P-256, P-256K, P-384, P-521
  class EC < Key
    property crv : String

    # PUB
    property x : String
    property y : String

    # PRIV
    property d : String?
  end

  # # Octet String
  # HS256 HS384 HS512
  # A128GCM A192GCM A256GCM A128CBC_HS256
  class OCT < Key
    property k : String
  end

  class Sets
    getter values : Array(RSA)?
    getter uri : String
    getter cache_duration : Time::Span = 24.hours

    def initialize(@uri, @cache_duration = 24.hours)
      jwks = HTTP::Client.get(uri).body

      Tasker.every(cache_duration) do
        @values = Array(RSA).from_json(HTTP::Client.get(uri).body, "keys").not_nil!
      end

      @uri = uri
      @values = Array(RSA).from_json(jwks, "keys").not_nil!
    end

    def select(kid : String) : RSA
      SimpleRetry.try_to(
        max_attempts: 3,
        retry_on: NilAssertionError,
        base_interval: 1.milliseconds,
      ) do |count|
        Log.info { "Retry attempt: #{count}" }
        Sets.new(@uri).values.not_nil!.find(&.kid.== kid).not_nil!
      end
    end
  end
end

def JWT.validate_with_jwks_uri(jwt_token : String, jwks_uri : String)
  # JWT Header
  jwt_header = ::JWT.decode(token: jwt_token, verify: false, validate: false)[1]
  raise ArgumentError.new("Typ #{jwt_header["typ"]} of invalid type (should be JWT)") unless jwt_header["typ"] == "JWT"

  # JWT Algo
  algo = ::JWT::Algorithm.parse(jwt_header["alg"].as_s)
  raise ArgumentError.new("Alg #{jwt_header["alg"]} not yet supported (only RS256)") unless algo.as?(::JWT::Algorithm::RS256)

  # JWT Public Key PEM
  jwk = JWK::Sets.new(jwks_uri).select(jwt_header["kid"].as_s)
  jwt_public_key_pem = jwk.to_pem

  ::JWT.decode(token: jwt_token, key: jwt_public_key_pem, algorithm: algo, verify: true, validate: true)
end
