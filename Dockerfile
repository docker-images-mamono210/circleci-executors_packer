FROM cimg/python:3.14

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

USER root

# Install Packer from the official HashiCorp APT repository.
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg openssh-client \
  && install -d -m 0755 /usr/share/keyrings \
  && curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | gpg --batch --yes --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && chmod 0644 /usr/share/keyrings/hashicorp-archive-keyring.gpg \
  && . /etc/os-release \
  && printf 'deb [arch=%s signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com %s main\n' \
    "$(dpkg --print-architecture)" "${UBUNTU_CODENAME:-${VERSION_CODENAME}}" \
    > /etc/apt/sources.list.d/hashicorp.list \
  && apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends packer \
  && rm -rf /var/lib/apt/lists/*

USER circleci

ENV PATH="/home/circleci/.local/bin:${PATH}"

# Install Ansible using the Python provided by the base image.
RUN python -m pip install --no-cache-dir --user ansible

# Install plugins under the runtime user's home directory.
RUN packer plugins install github.com/hashicorp/amazon \
  && packer plugins install github.com/hashicorp/ansible

# Fail the build if the installed commands cannot start.
RUN python --version \
  && ansible --version \
  && ansible-config --version \
  && ansible-playbook --version \
  && python -c "import ansible" \
  && packer --version \
  && packer plugins installed

CMD ["/bin/sh"]

