# A bare "server": Ubuntu with SSH and sudo, nothing else.
# Docker and Postgres are installed by hand in the exercise.
FROM ubuntu:24.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends openssh-server sudo curl ca-certificates iproute2 nano \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /run/sshd \
 && echo "ubuntu ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ubuntu \
 && sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 22
ENTRYPOINT ["/entrypoint.sh"]
