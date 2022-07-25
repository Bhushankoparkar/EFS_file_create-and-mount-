### User data file ###
### install java , install jenkins, nfs-common. ###
### mount in mnt directory permanently ###
locals {
user_data = <<EOF
#! /bin/bash
sudo apt-get update -y
sudo apt-get install openjdk-8-jdk -y
wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
sudo sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update -y
sudo apt-get install jenkins -y
sudo apt install nfs-common -y
echo "${aws_efs_file_system.this.dns_name}:/ /mnt nfs4 defaults 0 0" | sudo tee -a /etc/fstab 
sudo mount -a
EOF
}


# 1. ip
# 2. mounting pr
# 3. file system
# 4. defaults
# 5. 0
# 6. 0