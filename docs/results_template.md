# Results

## Environment

- OS: Microsoft Windows [Version 10.0.26200.8457] with Bash/Docker environment
- Docker version: Docker version 29.4.1, build 055a478
- Docker Compose version: Docker Compose version v5.1.3
- Date: 2026-05-18
- Brutus version/commit: Brutus dev; commit unknown; Go version go1.25.10; OS/Arch windows/amd64

## Vulnerable Results

- SSH: Found weak credential `labuser / password123`
  - Log: `results/vulnerable-ssh-20260518-215126.log`
  - Summary: `Results: 1 valid, 15 invalid, 0 errors (total: 16)`
- FTP: Found weak credential `ftpuser / ftp12345`
  - Log: `results/vulnerable-ftp-20260518-215126.log`
  - Summary: `Results: 1 valid, 16 invalid, 0 errors (total: 17)`
- HTTP Basic: Found weak credential `admin / admin123`
  - Log: `results/vulnerable-http-basic-20260518-215126.log`
  - Summary: `Results: 1 valid, 17 invalid, 0 errors (total: 18)`

Expected:

- SSH weak credential found: `labuser / password123`
- FTP weak credential found: `ftpuser / ftp12345`
- HTTP Basic weak credential found: `admin / admin123`

## Secured Results

- SSH: No weak credential found with the tiny lab wordlist
  - Log: `results/secured-ssh-20260518-215234.log`
  - Summary: `Results: 0 valid, 21 invalid, 0 errors (total: 21)`
- FTP: No weak credential found with the tiny lab wordlist
  - Log: `results/secured-ftp-20260518-215234.log`
  - Summary: `Results: 0 valid, 21 invalid, 0 errors (total: 21)`
- HTTP Basic: No weak credential found with the tiny lab wordlist
  - Log: `results/secured-http-basic-20260518-215234.log`
  - Summary: `Results: 0 valid, 21 invalid, 0 errors (total: 21)`

Expected:

- SSH weak credential not found
- FTP weak credential not found
- HTTP Basic weak credential not found

## Screenshots/Video

- Link: https://youtu.be/RWov7sdIHVk

## Notes

- Issues encountered:
  - The current Brutus CLI uses the `creds` subcommand; the initial root-level `--protocol` call was rejected.
  - The upstream Brutus `go.mod` required Go 1.25 or newer.
  - The HTTP Basic Auth container initially returned HTTP 500 because Nginx could not read the generated `.htpasswd` file.
- Fixes:
  - Updated `exploit_test.sh` to call `brutus creds --target ... --protocol ...`.
  - Updated the Brutus builder image to `golang:1.25-bookworm`.
  - Changed HTTP Basic `.htpasswd` permission to `0644` inside the container.
  - Re-ran vulnerable and secured tests; final logs show expected results with 0 runtime errors.

## HTTP Basic Fallback Note

Brutus is attempted first for HTTP Basic Auth using protocol `http`. If the installed Brutus CLI does not support the required syntax, `exploit_test.sh` records the issue in the HTTP result file and uses a tiny local-only `curl` fallback for HTTP Basic Auth only.
