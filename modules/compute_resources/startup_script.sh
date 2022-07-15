#! /bin/bash
# Copyright 2015 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



# [START startup]
set -v



# Talk to the metadata server to get the project id
PROJECTID=$(curl -s "http://metadata.google.internal/computeMetadata/v1/project/project-id" -H "Metadata-Flavor: Google")



# Install logging monitor. The monitor will automatically pickup logs sent to
# syslog.
# [START logging]
curl -sSO https://dl.google.com/cloudagents/add-google-cloud-ops-agent-repo.sh
bash add-google-cloud-ops-agent-repo.sh --also-install
# [END logging]



wget https://dl.google.com/cloudsql/cloud_sql_proxy.linux.amd64 -O cloud_sql_proxy
chmod +x cloud_sql_proxy
mv cloud_sql_proxy /usr/local/bin




cat > /etc/systemd/system/cloud-sql-proxy.service << EOF
[Install]
WantedBy=multi-user.target



[Unit]
Description=Google Cloud Compute Engine SQL Proxy
Requires=networking.service
After=networking.service



[Service]
Type=simple
WorkingDirectory=/usr/local/bin
ExecStart=/usr/local/bin/cloud_sql_proxy -instances=gcp-2021-2-bookshelf-satya:us-central1:bookshelf-sql-instance-10=tcp:3306
Restart=always
StandardOutput=journal
User=root
EOF



systemctl enable cloud-sql-proxy
systemctl start cloud-sql-proxy




# Install dependencies from apt
apt-get update
apt-get install -yq \
git build-essential supervisor python python-dev python-pip python3-pip libffi-dev \
libssl-dev



# Create a pythonapp user. The application will run as this user.
useradd -m -d /home/pythonapp pythonapp



# pip from apt is out of date, so make it update itself and install virtualenv.
pip install virtualenv



# Get the source code from the Google Cloud Repository
# git requires $HOME and it's not set during the startup script.
export HOME=/root
git config --global credential.helper gcloud.sh
git clone https://source.developers.google.com/p/gcp-2021-2-bookshelf-satya/r/book-shelf-repo -b steps /opt/app



# Install app dependencies
virtualenv -p python3 /opt/app/7-gce/env
/bin/bash -c "source /opt/app/7-gce/env/bin/activate"
/opt/app/7-gce/env/bin/pip install -r /opt/app/7-gce/requirements.txt --prefer-binary
/opt/app/7-gce/env/bin/python /opt/app/7-gce/bookshelf/model_cloudsql.py



# Make sure the pythonapp user owns the application code
chown -R pythonapp:pythonapp /opt/app




# Configure supervisor to start gunicorn inside of our virtualenv and run the
# application.
cat >/etc/supervisor/conf.d/python-app.conf << EOF
[program:pythonapp]
directory=/opt/app/7-gce
command=/opt/app/7-gce/env/bin/honcho start -f ./procfile worker bookshelf
autostart=true
autorestart=true
user=pythonapp
# Environment variables ensure that the application runs inside of the
# configured virtualenv.
environment=VIRTUAL_ENV="/opt/app/7-gce/env",PATH="/opt/app/7-gce/env/bin",\
HOME="/home/pythonapp",USER="pythonapp"
stdout_logfile=syslog
stderr_logfile=syslog
EOF



supervisorctl reread
supervisorctl update



# Application should now be running under supervisor
# [END startup]