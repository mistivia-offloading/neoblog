decrypted-socks
====================

This project is created using vibe coding.

## Download

    git clone https://git.mistivia.com/decrypted-socks.git

## Features

- Converts a SOCKS5 proxy requiring username/password authentication into a local SOCKS5 proxy without authentication.

## Setup

1. Copy `.env.example` to `.env` and fill in your upstream proxy details:
   ```
   cp .env.example .env
   ```
2. Run the proxy:
   ```
   ./start.sh
   ```

## License

This project is released under GPLv3.
