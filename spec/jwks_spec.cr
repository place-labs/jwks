require "./spec_helper"

describe JW do
  sample_jwt = "Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJSUzI1NiIsImtpZCI6Ilg1ZVhrNHh5b2pORnVtMWtsMll0djhkbE5QNC1jNTdkTzZRR1RWQndhTmsifQ.eyJpc3MiOiJodHRwczovL3BsYWNlb3N0ZXN0aW5nLmIyY2xvZ2luLmNvbS9mNTBlOGQ1NC0xMjAyLTRjMDUtYTU4YS00YWI0MzMxOTY0ZDIvdjIuMC8iLCJleHAiOjE2MDk4MTM5NzIsIm5iZiI6MTYwOTgxMDM3MiwiYXVkIjoiNDFlZjFiMWMtMDVlNS00OGZiLTg2NjAtYzkxNTgwYjYyMGViIiwib2lkIjoiMTRlYTFhMDgtYTI5NC00ZmM5LWEwNjgtYzg3ZmExNTU5MDM5Iiwic3ViIjoiMTRlYTFhMDgtYTI5NC00ZmM5LWEwNjgtYzg3ZmExNTU5MDM5IiwibmV3VXNlciI6dHJ1ZSwiZXh0ZW5zaW9uX1ByaW1hcnlFbWFpbCI6ImR1a2VAcGxhY2UudGVjaG5vbG9neSIsImdpdmVuX25hbWUiOiJEdWtlIiwiZW1haWxzIjpbImR1a2VAcGxhY2UudGVjaG5vbG9neSJdLCJ0ZnAiOiJCMkNfMV9zaWdudXBzaWduaW4xIiwibm9uY2UiOiI5ZTUwMjE0YS1hMjA3LTQyNDAtODJiZC0xZmNjMjIzNjIwZjMiLCJzY3AiOiJkZW1vLnJlYWQiLCJhenAiOiI4Nzg1M2VkZS0wYjMyLTRiZGUtYWZiZS1kZTY1YzExNDYxZjAiLCJ2ZXIiOiIxLjAiLCJpYXQiOjE2MDk4MTAzNzJ9.cDq1uk_9g5jZcUhup9-oH-9QG2Wb6wZcnRNwF0VAfUdk0Aw98koF3EF0h3JCmJ5_QsLb_sJ-nDbWBhP8W0AOtfGgDxM8T5_SQ3EhilqGRDp2XzPGh-XAe3BxNUxRxhL201zOB6k0ykdpc2Nu1B1aIXdfJ-WyVtAqIUm9ZzK_yQIrjjP1-w_KaUmI3ZBYYYA2QWQ0qWmcebTdjRGheDLhNTbL-zSVLL1pVaNGk3HWuULG9IvI8lpDccaURF4f_oH-8zG3HictWS-6As8jgZaWb1WrEtlpSztUXx395Q11kZ9yVamJYjZVthBoWGg8TWrSugrA47ycI-3_nzySB_rUPw"

  sample_jwks = %({
    "keys": [
      {"kid":"X5eXk4xyojNFum1kl2Ytv8dlNP4-c57dO6QGTVBwaNk","nbf":1493763266,"use":"sig","kty":"RSA","e":"AQAB","n":"tVKUtcx_n9rt5afY_2WFNvU6PlFMggCatsZ3l4RjKxH0jgdLq6CScb0P3ZGXYbPzXvmmLiWZizpb-h0qup5jznOvOr-Dhw9908584BSgC83YacjWNqEK3urxhyE2jWjwRm2N95WGgb5mzE5XmZIvkvyXnn7X8dvgFPF5QwIngGsDG8LyHuJWlaDhr_EPLMW4wHvH0zZCuRMARIJmmqiMy3VD4ftq4nS5s8vJL0pVSrkuNojtokp84AtkADCDU_BUhrc2sIgfnvZ03koCQRoZmWiHu86SuJZYkDFstVTVSR0hiXudFlfQ2rOhPlpObmku68lXw-7V-P7jwrQRFfQVXw"}
    ]
  })

  sample_jwt_pubkey_pem = "-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtVKUtcx/n9rt5afY/2WF
NvU6PlFMggCatsZ3l4RjKxH0jgdLq6CScb0P3ZGXYbPzXvmmLiWZizpb+h0qup5j
znOvOr+Dhw9908584BSgC83YacjWNqEK3urxhyE2jWjwRm2N95WGgb5mzE5XmZIv
kvyXnn7X8dvgFPF5QwIngGsDG8LyHuJWlaDhr/EPLMW4wHvH0zZCuRMARIJmmqiM
y3VD4ftq4nS5s8vJL0pVSrkuNojtokp84AtkADCDU/BUhrc2sIgfnvZ03koCQRoZ
mWiHu86SuJZYkDFstVTVSR0hiXudFlfQ2rOhPlpObmku68lXw+7V+P7jwrQRFfQV
XwIDAQAB
-----END PUBLIC KEY-----"

  sample_jwks_uri = "https://placeostesting.b2clogin.com/placeostesting.onmicrosoft.com/b2c_1_signupsignin1/discovery/v2.0/keys"

  it "Public::KeySets.get" do
    # Use WebMock here in the future
    keys = JW::Public::KeySets.get(sample_jwks_uri)
    keys.should eq(Array(JW::Public::Key).from_json(sample_jwks, "keys"))
  end

  it "Token.validate_with_jwks_uri" do
    expect_raises(JWT::ExpiredSignatureError) do
      JW::Token.validate_with_jwks_uri(sample_jwt.lchop("Bearer "), sample_jwks_uri).should be_a(Tuple(JSON::Any, Hash(String, JSON::Any)))
    end
  end

  it "Token.validate_with_jwks_uri in steps" do
    jwk = Array(JW::Public::Key).from_json(sample_jwks, "keys")[0]
    jwt_pubkey_pem = JW::Public::Key.to_pem(jwk)

    JW::Public::Key.to_pem(jwk).chomp.should eq(sample_jwt_pubkey_pem)
    ::JWT.decode(token: sample_jwt.lchop("Bearer "), key: jwt_pubkey_pem, algorithm: ::JWT::Algorithm::RS256, verify: true, validate: false).should be_a(Tuple(JSON::Any, Hash(String, JSON::Any)))
  end
end
