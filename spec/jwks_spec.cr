require "webmock"

require "./spec_helper"
require "./fixtures/*"

describe JWK do
  # openssl genpkey -algorithm RSA -out private.pem
  sample_rsa_pubkey_pem = File.read("./spec/fixtures/pubkey.pem")

  # openssl rsa -in private.pem -outform PEM -pubout -out pubkey.pem
  sample_rsa_private_pem = File.read("./spec/fixtures/private.pem")

  # https://irrte.ch/jwt-js-decode/pem2jwk.html
  sample_jwks = File.read("./spec/fixtures/jwk-pubkey.json")
  parsed_jwks = Array(JWK::Key).from_json(sample_jwks, "keys")
  sample_jwks_uri = "https://famous_uri.com/v2.0/keys"

  sample_data = {"id" => 1, "name" => "Nichiren"}
  sample_token = ::JWT.encode(sample_data, sample_rsa_private_pem, ::JWT::Algorithm::RS256, kid: parsed_jwks.first.kid)

  WebMock.stub(:get, sample_jwks_uri)
    .to_return(status: 200, body: sample_jwks)

  it "Sets.values" do
    keys = JWK::Sets.new(sample_jwks_uri).values
    keys.not_nil!.first.kid.should eq(Array(JWK::Key).from_json(sample_jwks, "keys").first.kid)
  end

  it "Token.validate_with_jwks_uri" do
    payload = JWT.validate_with_jwks_uri(sample_token.lchop("Bearer "), sample_jwks_uri)
    payload.should be_a(Tuple(JSON::Any, Hash(String, JSON::Any)))
    payload[0].to_json.should eq(sample_data.to_json)
  end

  it "Token.validate_with_jwks_uri in steps" do
    jwk = Array(JWK::Key).from_json(sample_jwks, "keys")[0].as(JWK::RSA)
    jwt_pubkey_pem = JWK::RSA.to_pem(jwk)

    JWK::RSA.to_pem(jwk).chomp.should eq(sample_rsa_pubkey_pem.chomp)
    payload = ::JWT.decode(token: sample_token.lchop("Bearer "), key: jwt_pubkey_pem, algorithm: ::JWT::Algorithm::RS256, verify: true, validate: false)
    payload.should be_a(Tuple(JSON::Any, Hash(String, JSON::Any)))
    payload[0].to_json.should eq(sample_data.to_json)
  end
end
