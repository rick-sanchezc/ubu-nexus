# host setup ubuntu
lsb_release  -r
Release:        22.04

# docker setup:

apt update

apt -y install ca-certificates curl apt-transport-https

curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

chmod a+r /etc/apt/keyrings/docker.gpg

echo   "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" |   sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

apt update

apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose

systemctl enable docker

systemctl start docker

# service setup

docker-compose build

docker-compose up -d


