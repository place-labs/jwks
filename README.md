# jwks

[![CI](https://github.com/place-labs/jwks/actions/workflows/ci.yml/badge.svg?branch=master)](https://github.com/place-labs/jwks/actions/workflows/ci.yml) [![Docs](https://img.shields.io/badge/docs-available-brightgreen.svg)](https://place-labs.github.io/jwks/) [![GitHub release (latest by date)](https://img.shields.io/github/v/release/place-labs/jwks)](https://img.shields.io/github/v/release/place-labs/jwks?style=flat-square)

Simple library that validates JWT against RS256 JWKS URI

- [Documentation](https://place-labs.github.io/jwks/)

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     jwks:
       github: place-labs/jwks
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
3. Commit your changes (`git commit -am 'feat(jwks.cr): Add some feature'`)
   - **Git Commit Convention**: This repository follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0-beta.2/)/ [the Angular convention](https://github.com/angular/angular/blob/22b96b9/CONTRIBUTING.md#-commit-message-guidelines). The preferred tool of git commit is [commitizen/cz-cli](https://github.com/commitizen/cz-cli).
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Duke Nguyen](https://github.com/dukeraphaelng) - creator and maintainer

## License

- [MIT](LICENSE)