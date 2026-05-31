# Two-Minute Demo Script

## 0:00-0:15 - Scope

Show `README.md`.

Say:

This is a self-contained Docker lab for authorized local testing only. It uses SSH, FTP, and HTTP Basic Auth services bound to localhost. The weak credentials exist only inside Docker and the wordlists are tiny lab-only files.

## 0:15-0:35 - Setup

Run:

```bash
./setup.sh
```

Say:

Setup prepares directories, marks scripts executable, builds the service images, and builds the Brutus runner from the official Praetorian repository.

## 0:35-0:55 - Vulnerable Lab

Run:

```bash
./run_vuln.sh
```

Say:

The vulnerable version starts three local targets: SSH on 2222, FTP on 2121, and HTTP Basic Auth on 8080.

## 0:55-1:20 - Vulnerable Findings

Run:

```bash
./exploit_test.sh
```

Show:

```text
SSH weak credential found
FTP weak credential found
HTTP Basic weak credential found
```

Say:

The tiny wordlist finds the intentionally weak credentials in all three vulnerable services.

## 1:20-1:40 - Secured Lab

Run:

```bash
./run_secured.sh
```

Say:

The secured version uses the same usernames and ports, but the passwords are stronger and absent from the lab wordlist.

## 1:40-1:55 - Secured Results

Run:

```bash
./exploit_test.sh --secured
```

Show:

```text
SSH weak credential not found
FTP weak credential not found
HTTP Basic weak credential not found
```

## 1:55-2:00 - Summary

Say:

The vulnerable configuration failed under weak credential testing. The secured configuration resisted the same tiny lab wordlist. No external systems were targeted.

