#!/bin/sh
##### Instance ID captured through Instance meta data #####
InstanceID=`/usr/bin/curl -s http://169.254.169.254/latest/meta-data/instance-id`
##### Set a tag name indicating instance is not configured ####
aws ec2 create-tags --region $EC2_REGION --resources $InstanceID --tags Key=Initialized,Value=false
##### Install Ansible ######
yum update -y
yum install git  -y
curl "https://bootstrap.pypa.io/get-pip.py" -o "/tmp/get-pip.py"
python /tmp/get-pip.py
pip install pip --upgrade
rm -fr /tmp/get-pip.py
pip install boto
pip install --upgrade ansible
##### Clone your ansible repository ######
git clone https://<your-ansible-repo>.git
cd your-ansible-repo
chmod 400 keys/*
# Keep ansible from verifying the identity of our workers
sudo sh -c 'sed -i.bak s/#host_key_checking/host_key_checking/ /etc/ansible/ansible.cfg'
# Put the internal key we created on master and make sure we can
# connect to ourselves
echo "${tls_private_key.internal_key.public_key_openssh}" | tee -a ~/.ssh/authorized_keys > ~/.ssh/id_rsa.pub
echo "${tls_private_key.internal_key.private_key_pem}" > ~/.ssh/id_rsa
chmod 600 ~/.ssh/id_rsa
# Setup our /etc/hosts on master
sudo sh -c 'echo \"${self.private_ip} master\" >> /etc/hosts'
sudo sh -c 'echo \"${join("\n", data.template_file.worker_hosts.*.rendered)}\" >> /etc/hosts'
# Setup our /etc/ansible/hosts on master
sudo sh -c 'echo \"${data.template_file.ansible_hosts.rendered}\" > /etc/ansible/hosts'
# Setup our /home/ec2-user/hadoop/etc/hadoop/workers on master
echo \"${data.template_file.hadoop_workers.rendered}\" > ~/workers
##### Run your ansible playbook for only autoscaled and not initialised instances ######
ansible-playbook setup_hadoop.yml --limit "tag_Name_AutoScaled:&tag_Initialized_false" 
##### Update TAG ######
aws ec2 create-tags --region $EC2_REGION --resources $InstanceID --tags Key=Initialized,Value=true