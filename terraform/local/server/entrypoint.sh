#!/bin/sh
# Install the public key passed in by Terraform, then run sshd in the foreground.
set -e
mkdir -p /home/ubuntu/.ssh
echo "$SSH_PUBLIC_KEY" > /home/ubuntu/.ssh/authorized_keys
chown -R ubuntu:ubuntu /home/ubuntu/.ssh
chmod 700 /home/ubuntu/.ssh
chmod 600 /home/ubuntu/.ssh/authorized_keys
ssh-keygen -A
exec /usr/sbin/sshd -D -e
