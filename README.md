# Brutus Mini Lab

Self-contained Docker mini-lab for demonstrating safe, authorized credential validation with [Praetorian Brutus](https://github.com/praetorian-inc/brutus).

This project is only for authorized local testing. It runs intentionally weak services inside Docker and only exposes them on localhost. No external systems are targeted, no real credentials are used, and the wordlists are tiny lab-only files.

## Overview

The lab contains vulnerable and secured versions of three services:

| Protocol | Vulnerable target | Secured target | Host exposure |
| --- | --- | --- | --- |
| SSH | `ssh-vuln` | `ssh-secured` | `127.0.0.1:2222` |
| FTP | `ftp-vuln` | `ftp-secured` | `127.0.0.1:2121` |
| HTTP Basic Auth | `http-basic-vuln` | `http-basic-secured` | `127.0.0.1:8080` |

The same tiny wordlist succeeds against the vulnerable version and fails against the secured version.

## Assignment Mapping

| Requirement | Where implemented |
| --- | --- |
| Code and configs | Dockerfiles, compose files, shell scripts, service configs |
| Docs | `README.md`, `ETHICS.md`, `CONTRIBUTIONS.md`, `docs/` |
| Non-weaponized test exploit | `exploit_test.sh`, localhost-only and tiny wordlists |
| GitHub-ready project | `.gitignore`, `Makefile`, docs, deterministic layout |
| Vulnerable and secured versions | `docker-compose.vuln.yml`, `docker-compose.secured.yml` |
| Three protocols | SSH, FTP, HTTP Basic Auth |
| Self-contained lab | Docker services plus local Brutus runner |

## Safety Scope

- This lab is self-contained.
- It runs only on localhost.
- The weak credentials are intentionally created only inside Docker.
- The test is non-weaponized and uses tiny lab-only wordlists.
- No external systems are targeted.
- `exploit_test.sh` does not accept host or IP range arguments.
- `exploit_test.sh` exits if its targets are changed away from `127.0.0.1` or `localhost`.
- Concurrency is intentionally low by default: 2 Brutus threads.

## Architecture

```text
Host machine
  |
  | localhost bindings only
  |
  +-- 127.0.0.1:2222 -> ssh-vuln or ssh-secured
  +-- 127.0.0.1:2121 -> ftp-vuln or ftp-secured
  +-- 127.0.0.1:8080 -> http-basic-vuln or http-basic-secured
  |
  +-- ./exploit_test.sh
        |
        +-- ./bin/brutus, brutus in PATH, or tools/run-brutus.sh
        +-- wordlists/users_*.txt
        +-- wordlists/passwords_lab.txt
        +-- results/*.log or results/*.json

Docker network: brutus_lab_net
```

## Prerequisites

- Docker
- Docker Compose v2 (`docker compose`)
- Bash
- `curl` for the HTTP Basic fallback path
- Optional: `shellcheck` for script linting

`setup.sh` builds local Docker images and builds Brutus from the official Praetorian source repository. This requires network access to Docker base images and GitHub during setup.

## Quick Start

```bash
git clone <repo-url>
cd brutus-mini-lab
./setup.sh
./run_vuln.sh
./exploit_test.sh
./run_secured.sh
./exploit_test.sh --secured
./stop_lab.sh
```

You can also use Make:

```bash
make setup
make vuln
make test
make secured
make test-secured
make stop
```

## Project Structure

```text
.
|-- README.md
|-- CONTRIBUTIONS.md
|-- ETHICS.md
|-- docker-compose.vuln.yml
|-- docker-compose.secured.yml
|-- setup.sh
|-- run_vuln.sh
|-- run_secured.sh
|-- stop_lab.sh
|-- exploit_test.sh
|-- verify_lab.sh
|-- Makefile
|-- .gitignore
|-- docs/
|   |-- demo_script.md
|   |-- architecture.md
|   |-- results_template.md
|   `-- sources.md
|-- results/
|   `-- .gitkeep
|-- wordlists/
|   |-- users_ssh.txt
|   |-- users_ftp.txt
|   |-- users_http.txt
|   `-- passwords_lab.txt
|-- services/
|   |-- ssh/
|   |-- ftp/
|   `-- http-basic/
`-- tools/
    |-- Dockerfile.brutus
    `-- run-brutus.sh
```

## Vulnerable Credentials

| Protocol | Username | Password |
| --- | --- | --- |
| SSH | `labuser` | `password123` |
| FTP | `ftpuser` | `ftp12345` |
| HTTP Basic Auth | `admin` | `admin123` |

These weak credentials exist only inside the vulnerable Docker containers.

## Secured Version

The secured containers use the same usernames but strong passwords that are not present in `wordlists/passwords_lab.txt`:

| Protocol | Username | Password |
| --- | --- | --- |
| SSH | `labuser` | `Use-A-Strong-Password-For-SSH-2026!` |
| FTP | `ftpuser` | `Use-A-Strong-Password-For-FTP-2026!` |
| HTTP Basic Auth | `admin` | `Use-A-Strong-Password-For-HTTP-2026!` |

The purpose is not production-grade hardening. The purpose is to show that weak credential testing succeeds against weak configuration and fails when the same users have stronger passwords outside the lab wordlist.

## Run The Vulnerable Lab

```bash
./run_vuln.sh
```

Expected targets:

| Protocol | Target |
| --- | --- |
| SSH | `127.0.0.1:2222` |
| FTP | `127.0.0.1:2121` |
| HTTP Basic Auth | `127.0.0.1:8080` |

## Run The Exploit Test

```bash
./exploit_test.sh
```

Expected vulnerable output:

```text
Summary:
- SSH weak credential found
- FTP weak credential found
- HTTP Basic weak credential found

Expected vulnerable result observed: all 3 weak credentials were found.
```

Results are saved in `results/`.

## Run The Secured Lab

```bash
./run_secured.sh
./exploit_test.sh --secured
```

Expected secured output:

```text
Summary:
- SSH weak credential not found
- FTP weak credential not found
- HTTP Basic weak credential not found

Expected secured result observed: no weak credentials were found.
```

## JSON Mode

If the installed Brutus build supports JSON output:

```bash
./exploit_test.sh --json
./exploit_test.sh --secured --json
```

Brutus JSON output contains only successful credentials. In secured mode the JSON result files should be empty or contain only diagnostic messages if the tool reports them.

## Brutus Runner Notes

`setup.sh` builds Brutus from the official `v1.5.1` release tag at `https://github.com/praetorian-inc/brutus` in `tools/Dockerfile.brutus`. It then tries to extract Linux and Windows binaries to `bin/brutus` and `bin/brutus.exe`.

`exploit_test.sh` resolves Brutus in this order:

1. `BRUTUS_CMD`, if set.
2. `./bin/brutus` or `./bin/brutus.exe`, if executable for the current shell.
3. `brutus` from `PATH`.
4. `tools/run-brutus.sh`, which runs the Dockerized Brutus helper.

The tested Brutus syntax is:

```bash
brutus creds --target 127.0.0.1:2222 --protocol ssh -U wordlists/users_ssh.txt -P wordlists/passwords_lab.txt -t 2
brutus creds --target 127.0.0.1:2121 --protocol ftp -U wordlists/users_ftp.txt -P wordlists/passwords_lab.txt -t 2
brutus creds --target 127.0.0.1:8080 --protocol http -U wordlists/users_http.txt -P wordlists/passwords_lab.txt -t 2
```

If the Brutus HTTP Basic Auth syntax changes or is unavailable, `exploit_test.sh` documents that event in the HTTP result log and uses a tiny `curl` fallback for HTTP Basic Auth only. SSH and FTP still require Brutus.

## Verification

Run:

```bash
./verify_lab.sh
```

The verification script checks Docker, Docker Compose, required files, script permissions, tiny wordlists, compose config validity, and whether vulnerable and secured services listen on localhost.

Optional script lint:

```bash
shellcheck setup.sh run_vuln.sh run_secured.sh stop_lab.sh exploit_test.sh verify_lab.sh tools/run-brutus.sh
```

## Two-Minute Demo Video

Use `docs/demo_script.md` as the speaking and command plan:

- 0:00-0:15 show README and scope.
- 0:15-0:35 run `./setup.sh`.
- 0:35-0:55 run `./run_vuln.sh`.
- 0:55-1:20 run `./exploit_test.sh` and show 3 findings.
- 1:20-1:40 run `./run_secured.sh`.
- 1:40-1:55 run `./exploit_test.sh --secured` and show no findings.
- 1:55-2:00 summarize vulnerable vs secured.

## Troubleshooting

If Docker cannot bind a port, stop previous containers:

```bash
./stop_lab.sh
```

If Brutus is not found:

```bash
./setup.sh
```

Or set a local command:

```bash
BRUTUS_CMD="brutus" ./exploit_test.sh
```

If HTTP Basic Auth does not work through Brutus, check `results/*http-basic*`. The script will try the documented `curl` fallback for HTTP Basic Auth only when Brutus syntax is not usable.

If using the Dockerized Brutus helper, `tools/run-brutus.sh` uses Docker host networking so `127.0.0.1` remains the lab host target. On platforms where Docker host networking is unavailable, use a native Brutus binary through `./bin/brutus`, `PATH`, or `BRUTUS_CMD`.

## Limitations

- This is an educational localhost lab, not a production hardening guide.
- The secured version demonstrates password resistance to a tiny lab wordlist only.
- FTP is included because the assignment requires multiple protocols; it is not recommended for modern production use without stronger controls.
- Brutus is built from the official repository during setup, so network access is needed once.

## Sources And Inspiration

See `docs/sources.md` for sources. No exploit code was copied from external writeups. The lab design is original and uses intentionally weak local Docker services only.

## Ethical And Legal Note

Only run this project on systems you own or are explicitly authorized to test. Do not adapt the scripts to target third-party systems, public IP ranges, or real credentials.
