# Architecture

## Docker Network

Both compose files use a dedicated bridge network named `brutus_lab_net`. The services can communicate inside Docker, but the assignment workflow tests only the localhost bindings exposed to the host.

## Service Containers

The lab has three protocols:

| Protocol | Vulnerable container | Secured container | Host binding |
| --- | --- | --- | --- |
| SSH | `brutus-ssh-vuln` | `brutus-ssh-secured` | `127.0.0.1:2222` |
| FTP | `brutus-ftp-vuln` | `brutus-ftp-secured` | `127.0.0.1:2121` |
| HTTP Basic Auth | `brutus-http-basic-vuln` | `brutus-http-basic-secured` | `127.0.0.1:8080` |

Each vulnerable container creates an intentionally weak password. Each secured container keeps the same username but uses a stronger password outside `wordlists/passwords_lab.txt`.

## Brutus Runner

`tools/Dockerfile.brutus` builds Brutus from the official Praetorian GitHub repository. `setup.sh` builds this image and tries to copy the binary to `bin/brutus`.

`exploit_test.sh` uses Brutus from:

1. `BRUTUS_CMD`, if provided;
2. `bin/brutus`;
3. `brutus` in `PATH`;
4. `tools/run-brutus.sh`, the Dockerized helper.

## Vulnerable And Secured Split

The two compose files use the same host ports. The run scripts stop the previous lab before starting the next one. This makes the demo simple:

```bash
./run_vuln.sh
./exploit_test.sh
./run_secured.sh
./exploit_test.sh --secured
```

## Localhost-Only Exposure

All service ports are bound with `127.0.0.1:host_port:container_port`. This prevents the containers from listening on all host interfaces.

`exploit_test.sh` also enforces this in code:

- it does not accept arbitrary target arguments;
- it checks that targets are `127.0.0.1` or `localhost`;
- it checks that ports match the lab ports;
- it exits if someone changes the target variables to external hosts.

