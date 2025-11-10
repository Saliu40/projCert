End-to-End DevOps Pipeline Using Jenkins, Ansible, Docker & GitHub

Author: Abdullahi Wisdom Saliu — DevOps & Cloud Engineer


<img width="630" height="653" alt="Screenshot 2025-03-04 230420" src="https://github.com/user-attachments/assets/ebc362db-2501-41fb-8b7c-102cde21b565" />

How Continuous Integration (CI) and Continuous Deployment (CD) Solve the Issues​
AppleBite Co. faced challenges in managing code deployments efficiently. Before implementing CI/CD, they likely had manual deployments, inconsistencies in
environments, longer release cycles, and increased risk of errors. CI/CD provides a structured and automated approach to address these problems.

<img width="839" height="744" alt="Screenshot 2025-03-04 231550" src="https://github.com/user-attachments/assets/9a3bd5d2-b302-4cd0-971b-b62755022929" />
Image Above Is Our Project Requirement.

1. Introduction
This training manual provides a step-by-step approach to implementing an automated CI/CD pipeline for a PHP-based web application. The deployment process uses GitHub for source control, Jenkins for Continuous Integration, Ansible for server configuration automation, and Apache Web Server for application hosting. The goal of this pipeline is to reduce manual deployment effort, increase consistency, and enable rapid and reliable releases.
2. Prerequisites
- Basic understanding of Linux command line
- GitHub account with repository access
- Jenkins server installed
- Ansible installed on Jenkins or a control node
- Apache Web Server installed on the target host
- PHP application source code prepared

3. Pipeline Architecture Overview
Below is the high-level workflow for this pipeline:

Developer → GitHub → Jenkins CI Pipeline → Ansible Configuration & Deployment → Apache Web Server → User Access
##Solution##
In solving the problem, we applied Infrastructure as Code (IaC) using Vagrant to provision and configure two virtual machines automatically. Each VM was assigned a private IP address with the required ports forwarded for communication. One VM was designated as the Jenkins Master Node, responsible for managing pipelines and orchestration, while the second VM acted as the Jenkins Slave Node (Test Server), where the build and deployment tasks were executed. This approach provided a consistent, reproducible environment for CI/CD automation.

Order of Execution​
This project is divided into stages:​

Step 1: Setting up the environment (Slides 7 - 23)​

Step 2: Configuring the Jenkins Master Node and Jenkins Slave Node
(Test Servers) (Slides 24 - 31)​

Step 3: Configuring Jenkins to pull the pipeline script from GitHub using
SSH (Slides 32 - 34)​

Step 4: Creating a Webhook for GitHub-Jenkins Automation (Slides 3 - 38)​

Step 5: Setting up Jenkins Pipelines (Slides 39 - 59)​

  -Job 1: Install and configure the Puppet agent on the slave node.​

  -Job 2: Push an Ansible configuration to the test server to install Docker.​

  -Job 3: Pull the PHP website and Dockerfile from the Git repository, build the Docker image, and deploy the PHP container.​

  -Job 4: If Job 3 fails, delete the running container on the test server​

Step 6: The End​.


Step 1: Setting up Project Environment​
<img width="1182" height="980" alt="Screenshot 2025-02-25 122811" src="https://github.com/user-attachments/assets/4e9ea494-0270-417a-bdb0-62520ca0b0ec" />
Above is a Dabian Vagrantfile we used to Launched two VM, one as Jenkins Master, the other as Test_server(Jenkins slave node)​

The two VMs as Master & Test_server
<img width="964" height="984" alt="Screenshot 2025-02-25 122832" src="https://github.com/user-attachments/assets/1521afc0-bc0c-4bb6-89a5-990691cc2849" />
Vagrant Up is a command we used to Provision the VMs after configuring my Vagrantfile.​ Vagrant Status is a command to check if the VMs are Up and running after Provisioning. The Two VMs are Up and Running 

Updating the VMs Package nmanager to the latest​
<img width="1845" height="851" alt="Screenshot 2025-02-25 123404" src="https://github.com/user-attachments/assets/bf1751ac-7bed-4f2c-a114-6b390d7448ba" />
Vagrant SSh master​
Vagrant ssh test_server1​
I used the above command to ssh into the 2VMs & Update their package managers with the command: <sudo apt update && sudo apt upgrade>

Tools to Install on the Master VM(Jenkins Master Node)​
For the purpose of this Project, we need to
configure the following tools on our master VM:​
Jenkins​
Ansible​
Git​
Required Jenkins plugins (Build Pipeline Plugin, Post-build Task Plugin).

#Codes for Configuring Jenkins on the Master VM
sudo apt update​

sudo apt install fontconfig openjdk-17-jre​

java -version​

openjdk version "17.0.13" 2024-10-15​

OpenJDK Runtime Environment (build 17.0.13+11-Debian-2)​

OpenJDK 64-Bit Server VM (build 17.0.13+11-Debian-2, mixed mode, sharing)​

sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \​ https://pkg.jenkins.io/debian/jenkins.io-2023.key​

echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc]" \​ https://pkg.jenkins.io/debian binary/ | sudo tee \​/etc/apt/sources.list.d/jenkins.list > /dev/null​

sudo apt-get update​

sudo apt-get install jenkins​
<img width="895" height="469" alt="Screenshot 2025-02-25 130100" src="https://github.com/user-attachments/assets/76341db9-3603-45ff-9fc9-02d0efcdb762" />
Jenkins is Up & Running.
<img width="945" height="395" alt="Screenshot 2025-02-25 131157" src="https://github.com/user-attachments/assets/91733a5c-9a14-46bc-ae0f-8a685017e017" />
Getting the Jenkins Default password

<img width="1395" height="1032" alt="Screenshot 2025-02-25 131223" src="https://github.com/user-attachments/assets/de61f601-94ed-41b4-8f64-9fadd80e93c9" />
Accessing Jenkins Gui using MasterVM Ip & Jenkins Default port 8080, which was already defined & forwarded on the jenkinsfile. Cat, copy & paste the jenkins initial passwd.

<img width="1705" height="958" alt="Screenshot 2025-02-25 132507" src="https://github.com/user-attachments/assets/967530a0-6742-446b-bae4-88464d7ed8a0" />
Installing Jenkins Default Plugins, & Creating  Admin User.​
<img width="1920" height="1080" alt="Screenshot (26)" src="https://github.com/user-attachments/assets/421f6caf-c85f-4173-8cd2-2bf14047a5d7" />
Jenkins Default GUI​
<img width="1792" height="953" alt="Screenshot 2025-02-25 133453" src="https://github.com/user-attachments/assets/bd77f6be-f8b6-4b77-8590-d01b6bd7377e" />

Installing two Plugins Necessary for this Project​
<img width="945" height="901" alt="Screenshot 2025-02-25 142314" src="https://github.com/user-attachments/assets/29559574-ad43-45d8-ab99-b8ce0656e896" />

Ansible and Git Installation on the Master VM​
we use Bash script to install Ansible, while we use command to install git 
sudo apt install git –y to install git​
<img width="929" height="484" alt="Screenshot 2025-02-25 144626" src="https://github.com/user-attachments/assets/642f2f04-6af6-4c58-92bd-9322da4508e8" />
Ansible & Git Installed.



Configuring Ansible on the Master VM To Connect with the Test_server1(jenkins slave node)​
<img width="888" height="976" alt="Screenshot 2025-02-26 100337" src="https://github.com/user-attachments/assets/5bb9b01d-ba19-429c-a591-18f5d8ad76ba" />
Since ansible work with ssh, we need to configure our 2VMs so they can be able to talk to each other. 
Run the command: 'sudo nano /etc/ssh/sshd_config' to make adjustment on the sshd_config file.​
  -Set Permitrootlogin to yes​
  -Set publikeyAuthentication to yes​
  -Set Permitrootlogin to yes​
  Save it and exit the file​
###Repeat same Process on the Test_server1 VM​

Ansible Inventory File

<img width="621" height="428" alt="Screenshot 2025-02-26 100719" src="https://github.com/user-attachments/assets/d34c6a69-a5f8-463f-842e-a559e21bbe7b" />

Either use nano or vim file editor to create an inventory.ini file (host) where we define our nodes ip (test_server1), save and exit​.

Defining Ansible Configuration File(Ansible.cfg)
<img width="575" height="509" alt="Screenshot 2025-02-26 101348" src="https://github.com/user-attachments/assets/40477591-df98-4752-a4b8-83fcad974f74" />

We defined our Ansible configuration file on the master VM, <nano ~/ansible.cfg> we use the file to define Inventory location, to control ssh behavior, set privileges, & the remote user location. Save the file $ exit​
Run the command <export ANSIBLE_CONFIG=~/ansible.cfg> so Ansible can recorgnized it as its config file while performing any operation​
​
<img width="522" height="133" alt="Screenshot 2025-02-26 101413" src="https://github.com/user-attachments/assets/37e584cf-ed4b-4821-9ed3-872b9af8b36b" />

Configuring SSH Keys As Ansible Uses Secure Shell to execute its tasks

<img width="522" height="694" alt="Screenshot 2025-02-26 101842" src="https://github.com/user-attachments/assets/025a486e-5def-464b-9a85-053292e1da06" />

SSH-Keygen, use the command to generate sshkeys on the master VM, 
cat the public key and copy it to Authorized_keys file inside ssh directory onour slave nodes(test_server1) as this will enable a Ansible handshake between both VMs.​

<img width="553" height="276" alt="Screenshot 2025-02-26 101851" src="https://github.com/user-attachments/assets/97926bce-bd8f-479d-828b-a597b5a0a22e" />

either copy the public key maually or you automate it


Ansible Ping

<img width="578" height="606" alt="Screenshot 2025-02-26 103745" src="https://github.com/user-attachments/assets/3c66c580-6d33-41dc-8da0-5995c1e46ecd" />

after those configuration is done, we run the command: ansible -I inventory.ini test_server1 –m ping.​
This command is to test if the master VM can Ansibly connect to the Slave Node(test_server1)VM. If ansible is not properly configured, its throws an error at this stage​.

***#####Tools to Install on the Test Server1(Jenkins Slave Node)​#####***

For the purpose of this Project, we need to configure the following
tools on our Test_server  VM:​

The Project Requirement State that we should Install the Following Tools Manually:​
  -Python​
  -OpenSSH-server​
  -Git​
While The Below tasks should be automated through Jenkins by
creating a pipeline: ​

​  1. Install and configure puppet agent on the slave node (Job 1) ​
  2. Push an Ansible configuration on test server to install docker (Job 2) ​
  3. Pull the PHP website, and the Dockerfile from the git repo and build
      and deploy your PHP docker   container. After. (Job 3) ​
  4. If Job 3 fails, delete the running container on Test Server.​

Installations Of Java(Open JDK17), Git, Python, And OpenSSH- Server On The Test_server1(Jenkins worker Node).​

<img width="641" height="340" alt="Screenshot 2025-03-03 002020" src="https://github.com/user-attachments/assets/8c1a12b6-91e1-4425-8fd7-9d22a3da0224" />

***Step 2: Configuring Jenkins Master Node & Slave Nodes(Test_server)***​
Setting up Jenkins on Master VM:​
After Configuring Jenkins GUI & Required Plugins On MasterVM,​ We will set Up a Jenkins Node, configure it to Communicate with jenkins slave VM (Test_server).​

​Seting up Slave Jenkins Node:​
  -Create a new user for Jenkins on the slave.​
  -Start the Jenkins agent on the slave.​
  -Connect the slave node to Jenkins master.​


Add SSH Credencials To Jenkins:​
switch to Jenkins user on Ur Jenkins MasterVM, ssh-keygen to generate ssh-keys,  cd int ~ssh dir,  cat & copy the id_rsa(private_key), we use it to create credential as shwon below ​

<img width="948" height="1026" alt="Screenshot 2025-02-26 111914" src="https://github.com/user-attachments/assets/92fc332e-a61a-4f5b-8653-7e94938ab7c3" />

Adding Jenkins User to the Test_server(we need to add jenkin user so that jenkins running on master VM can connect to the slave node.)​

<img width="390" height="471" alt="Screenshot 2025-02-26 104723" src="https://github.com/user-attachments/assets/9f8abd76-09c8-4bb2-a148-0b71203160f7" />

Copy ssh-publickey from Master VM Jenkins User, to Authorized_keys under Test_server slave node ssh Directory ​
​​
<img width="808" height="374" alt="Screenshot 2025-02-26 115043" src="https://github.com/user-attachments/assets/f3f5590d-4b60-47b4-b942-1460f1975723" />

Copy the same ssh-key created on slide19 but this time, it will be the public-key(cat id_rsa.pub, copy the keys), switch to jenkins User created on Test_server VM, chack slide 20. cd to ssh-dir, and create Authorized_keys file, paste the keys, save and exit, #change the file mode to 600 when through.​

​
Adding Jenkins Node: we go to manage Jenkins, click on Nodes, add a node and configure it as seen below, click save.​
​
<img width="934" height="851" alt="Screenshot 2025-02-26 113317" src="https://github.com/user-attachments/assets/06b280fd-61df-4d01-80bc-bae43258efcd" />

<img width="947" height="995" alt="Screenshot 2025-02-26 113332" src="https://github.com/user-attachments/assets/26899585-c6c4-499d-9910-6f95792d487f" />

If correctly configured, the test_server node should be online as shown below, which means Jenkins Master & Slave Nodes has been configured successfully.​

<img width="1906" height="637" alt="Screenshot 2025-02-26 113636" src="https://github.com/user-attachments/assets/fbd1d1bc-42b3-41e4-8ff8-3573da9ab7cf" />

Time to Create & Run a Freestyle Project To Test Jenkins Master & Slave Nodes:​
from Ur jenkins dashboard, create a new freestyle project to run a shell script as shown below to test communication between the two VM​.

<img width="1910" height="948" alt="Screenshot 2025-02-26 123234" src="https://github.com/user-attachments/assets/b32485d4-15d7-4d96-8a36-072b2004c58a" />
<img width="1919" height="1024" alt="Screenshot 2025-02-26 123252" src="https://github.com/user-attachments/assets/c3cbd941-18a7-4652-bce4-ea65623de12f" />

Bash Script Was a Success, below is the console output.​
<img width="1516" height="686" alt="Screenshot 2025-02-26 123206" src="https://github.com/user-attachments/assets/567b89cd-b3a7-460c-9488-aa3e2e8f8ce7" />

<img width="957" height="893" alt="Screenshot 2025-02-26 232023" src="https://github.com/user-attachments/assets/f0321aec-649b-45e3-ba3b-4dfb1a78ddd5" />

**###Step3:** 
configuring Jenkins to pull pipeline script from GitHub Using SSH​

