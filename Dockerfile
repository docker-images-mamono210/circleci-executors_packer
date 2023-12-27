FROM circleci/golang

# Install required packages
RUN sudo apt-get update \
  && sudo apt-get install software-properties-common \
  && sudo apt-get install python3-pip

# Install Packer
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - \
  && sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
  && sudo apt-get update \
  && sudo apt-get install packer \
  && packer plugins install github.com/hashicorp/amazon \
  && packer plugins install github.com/hashicorp/ansible

# Install Ansible
RUN pip3 install ansible --user

CMD ["/bin/sh"]
