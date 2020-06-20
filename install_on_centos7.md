yum clean all && yum -y update
yum install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
yum clean all
yum repolist all
yum install -y docker-ce docker-ce-cli containerd.io
curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
systemctl enable docker
cd /usr/share
mkdir RNMS
cd RNMS
yum -y install git
git init
git remote add origin https://github.com/rensenti/RNMS.git
git remote -v
git pull origin master
