# Sources

- Brutus GitHub repository: https://github.com/praetorian-inc/brutus
- Docker documentation: https://docs.docker.com/
- Docker Compose documentation: https://docs.docker.com/compose/
- OpenSSH project/manual pages: https://www.openssh.com/manual.html
- vsftpd project: https://security.appspot.com/vsftpd.html
- Nginx documentation: https://nginx.org/en/docs/

No exploit code was copied from external writeups.

The lab design is original and only uses intentionally weak local Docker services. Any reused Docker image or package is listed below:

- `debian:bookworm-slim` for SSH and FTP service containers.
- `nginx:1.27-alpine` for the HTTP Basic Auth container.
- `golang:1.26-bookworm` and `debian:bookworm-slim` for the Brutus builder/runtime image.
- Debian packages: `openssh-server`, `vsftpd`, `ca-certificates`, `git`.
