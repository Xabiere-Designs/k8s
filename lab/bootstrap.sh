#!/bin/bash
set -euxo pipefail

# Docker engine (native, in-distro — same approach that unstuck the mancave)
curl -fsSL https://get.docker.com | sh
usermod -aG docker ubuntu

# kubectl (latest stable)
KVER=$(curl -L -s https://dl.k8s.io/release/stable.txt)
curl -Lo /usr/local/bin/kubectl "https://dl.k8s.io/release/${KVER}/bin/linux/amd64/kubectl"
chmod +x /usr/local/bin/kubectl

# kind
curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
chmod +x /usr/local/bin/kind

# marker so you can confirm cloud-init finished
touch /home/ubuntu/.bootstrap-done
