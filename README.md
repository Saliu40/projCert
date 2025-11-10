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
