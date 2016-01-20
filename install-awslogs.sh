#!/bin/sh

yum install -y awslogs

echo '[plugins]
cwlogs = cwlogs
[default]
region = us-east-1
' > /etc/awslogs/awscli.conf
mv /etc/awslogs/awslogs.conf /etc/awslogs/awslogs.conf.bak
curl -L https://raw.githubusercontent.com/amimoto-ami/install-aws-logs/master/create-awscli-conf.sh | bash >> /etc/awslogs/awslogs.conf

cd /etc/update-motd.d/
if [ -f /etc/update-motd.d/30-banner ]; then
 rm -f /etc/update-motd.d/30-banner
fi
wget https://raw.githubusercontent.com/amimoto-ami/install-aws-logs/master/update-motd.d/30-banner
wget https://raw.githubusercontent.com/amimoto-ami/install-aws-logs/master/update-motd.d/35-middlewares
chmod +x 30-banner
chmod +x 35-middlewares
update-motd
