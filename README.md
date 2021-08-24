# jwks

Simple library that validates JWT against RS256 JWKS URI

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     jwks:
       github: place-lab/jwks
   ```

2. Run `shards install`

## Usage

```crystal
require "jwks"
```

## Development

### Docker

```bash
docker build . -t jwks && docker run jwks
```

### Without Docker

- You need to have openssl@1.1.1
- For MacOS users, if Crystal has not installed this for you
```bash
brew install openssl@1.1.1

shards install
crystal spec
crystal tool format --check
bin/ameba
```

## Contributing

1. Fork it (<https://github.com/dukeraphaelng/jwks/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Duke Nguyen](https://github.com/dukeraphaelng) - creator and maintainer
