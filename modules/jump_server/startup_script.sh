#! /bin/bash

set -v 

# Talk to the metadata server to get the project id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")


# installing git
sudo apt update
sudo apt install git -y

# installing ansible
sudo apt install ansible -y

# installing dependencies
sudo apt install build-essential python3 python3-pip -y

# Get the source code from the Google Cloud Repository
# git requires $HOME and it's not set during the startup script.
export HOME=/root
git config --global credential.helper gcloud.sh
git clone https://source.developers.google.com/p/gcp-2021-2-bookshelf-dineshs/r/bookshelf_cloud_repo_ansible /etc

# ansible-playbook main.yml