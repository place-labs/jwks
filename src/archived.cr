# require "http/client"

# # TODO: Write documentation for `JWKS`
# module JWKS
#   # Convert this to use JWT::Algorithm enum with from_json(input : String) later
#   alias SigningKey = NamedTuple(kid: String, alg: String, public_key: String, rsa_public_key: String, get_public_key: Proc)

#   class Error < Exception
#     def initialize(message : String)
#       super(message)
#     end

#     class SigningKeyNotFound < Exception
#       def initialize(kid : String)
#         super("Unable to find a signing key that matches #{kid}")
#       end
#     end
#   end

#   class Key
#     def get_public_key
#     end
#   end

#   class Client
#     extend self
#     VERSION = "0.1.0"

#     # Main Configuration
#     property rate_limit : Bool = false
#     property cache : Bool = true
#     property timeout : Time::Span = 30000.seconds

#     # Others
#     property get_keys_interceptor : Bool? = nil

#     property jwks_uri : String
#     property request_headers
#     property get_signing_key : Proc(self, *opts)

#     # Initialize debugger here

#     def initialize(@rate_limit, @cache, @timeout, @get_keys_interceptor)
#       # // Initialize wrappers.

#       if @get_keys_interceptor
#         @get_signing_key = get_keys_interceptor
#         #   this.getSigningKey = getKeysInterceptor(this, options);
#       end

#       if @rate_limit
#         #   this.getSigningKey = rateLimitSigningKey(this, options);
#       end

#       if @cache
#         #   this.getSigningKey = cacheSigningKey(this, options);
#       end
#     end

#     # Instance methods
#     def get_signing_key(kid : String) : Key
#       keys = self.get_signing_keys
#       key = keys.find { |k| k.kid == kid }
#       raise Error::SigningKeyNotFound.new(kid) unless key
#       key
#     end

#     def get_signing_keys : Array(Key)
#       keys = self.get_keys

#       if keys.nil? || keys.empty?
#         raise JWKS::Error.new("The JWKS endpoint did not contain any keys")
#       end

#       signing_keys = retrieve_signing_keys(keys)

#       if signing_keys.empty?
#         raise JWKS::Error.new("The JWKS endpoint did not contain any signing keys")
#       end

#       # Log signing keys here

#       signing_keys
#     end

#     def get_keys : Array(JSON::Any)
#       # Add agent, timeout and fetcher here
#       response = HTTP::Client.get(@uri, headers: @headers, body: "Hello!")
#       JSON.parse(response.body).as_h["keys"].as_a
#     end

#     def retrieve_signing_keys(keys : Array(SigningKey))
#     end
#   end
# end
