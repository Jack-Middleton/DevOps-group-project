# QAProject-team-3

# Contents

* Introduction
* Project Planning
* MVP
* CI Pipeline
* Application
* Budget
* Retrospective

# Introduction
The overall project scope was to take the following externally created application (broken into two repositories): 

https://github.com/spring-petclinic/spring-petclinic-angular (Front end)

https://github.com/spring-petclinic/spring-petclinic-rest (Back end)

and automate its development. This involved devising a plan for workflow, a design of the project structure depending on the application contents and planning for any further deployments without problems being caused by scalability.

# Project Planning

## Risk assessment

Before commencing this project, we undertook a risk assessment to help us determine any possible risks or blockers to the project so that we could ensure that we put measures in place to reduce or eliminate these risks. The full risk assessment can be seen below.

![RISK ASSESSMENT](https://github.com/Jack-Middleton/DevOps-group-project/blob/0c194c6b176ae1f458a2b71b9d07abd1b3ca6cf9/images/Risk%20Assessment.png)

During the project we had team absence and issues with the VMs so our control measures for these risks were helpful. 

# MVP

As the timeline for this project was tight, we agreed the following as a minimum viable product (MVP): 

* The application to be deployed without a persisting MYSQL database
* The installation of the software required to be done manually instead of writing an Ansible Playbook
* The application to be deployed via one Jenkins pipeline from the main branch on the GitHub
* The application to be deployed without replicas
* A clear readme written
* A presentation created without a rolling update feature branch for the demonstration

# CI Pipeline 

The key requirements of a CI pipeline are:

* Clear and tracked project requirements - usually using software specifically designed for this
* A version control system that maintains a single source code repository for the project
* Automated building of the application
* Automated testing with error reports generated
* Successful builds stored in an artefacts repository
* Automated deployment of the code

## Project Tracking

To track the progress of this project we decided to use Jira software. It was chosen because it was a tool the whole team was familiar with, and it allowed us to work in sprints using a kanban style board. 

The team had an initial discussion about the main tasks required to complete this project and how to break down the work into sections. There were three main sections - setup, deployment and documentation. The tasks for these sections were organised into sprints and distributed across the team. For this project, story points were not used, due both to a lack of experience within the team to accurately assign story points, and project time constraints.
If the team was deployed on a similar project in the future, story points would be used to ensure an even distribution of tasks and workload across the team. 

Each day we had a daily stand-up to discuss the tasks for the day, what had been achieved the day before, any blockers and plans for the day. Additional tasks were then assigned and there were discussions around how to resolve any blockers. These stand-ups allowed the team visibility on each other’s work and ensured that everyone had a task to do. Peer programming was used so that no one in the team had to work alone, allowing knowledge sharing and joint problem solving.

![JIRA BOARD](https://github.com/Jack-Middleton/DevOps-group-project/blob/0c194c6b176ae1f458a2b71b9d07abd1b3ca6cf9/images/Jira%20Board%20v2.png)

## Version Control System

We used git as our VCS and GitHub to store our repository. We chose to use GitHub because it’s a well established tool that everyone was familiar with and the application that we were deploying was stored on it. GitHub also connects to Jenkins via a webhook which allows us to automatically build any updates to the main branch of our repository.

We created our own repository for the project and moved the files from the application's frontend and backend repositories into our repository. 

As people in the team were all working on different sections of the deployment, we used the feature-branch model to ensure that there were no code conflicts. We only pushed to the main branch once we were confident that we had the application working correctly. 

## Set up 

After completing our project planning via Jira, discussing and selecting the tools we will use and deciding what our minimum viable product looks like, we started the process of setting up the environments we thought we would need.

This initially involved making sure all group members had access to the github repository we would be working from and the AWS account that we would be operating with.

Once this was completed we went on to create a virtual machine.  On that we installed Terraform, used Terraform to provision a virtual machine and a managed EKS cluster with two nodes inside it. This was the foundation that we began building our project on.

### Tools and justification:

AWS - We chose to use AWS as our cloud platform due to a number of reasons: 

* The range of options available to customise your virtual machines is incredibly useful for our given project. 
* EKS is available which lets you deploy Kubernetes clusters on AWS without having to manually install Kubernetes on EC2 compute instances, which would save us a lot of time. 
* It has their Docker container images stored securely in ECR (Elastic Container Registry). Every time a container spins up, it securely pulls its container image directly from ECR.

 VSC (Visual Studio Code) - We chose VSC as our a source-code editor for the following reasons:

* As a group we have experience using VSC, we agreed it was user friendly and we would be comfortable coding using its interface
* We know it works well with all the services/tools that we plan to use 
* Comes with excellent plug-in support such as remote-ssh 
* It helps identify syntax errors

Terraform - We decided to use Terraform as our IaC (Infrastructure as Code) tool for the following reasons:

* We agreed again that Terraform was a tool we were all familiar with, reducing time spent learning how to use it.  
* It could help us quickly create new VMs when required during the project. This would greatly reduce the time spent creating and destroying virtual machines when needed.
* We considered that we could use Cloudformation instead, however Terraform has increased flexibility over Cloudformation and we thought this would be easier to use for our project as a result.

## Automated building of the application

Docker is an open-source containerisation tool which we used to containerise the application. It was chosen as a tool because the application already had a Dockerfile written for the frontend, and an image created and stored in DockerHub for the back-end. It also allowed us to use a MySQL image for the database instead of using a local database. 

As the backend had to be amended to point to a MySQL database, we created a Dockerfile to recreate the image with the new configuration. 

Once the application was containerised, we used a Jenkins pipeline to automate the build for this project. All builds are stored and displayed on the Jenkins pipeline interface. Successful builds display all green blocks and means success in the deployment of the application. Any red blocks mean that a stage has failed and will cancel the remaining steps halting the application from being deployed. 

Jenkins was chosen and used during the project as the build automation tool in the CI pipeline because it is a tool we have become extremely familiar with during the course of the three projects. It’s also a tool that is open-source, which means that it can be implemented freely into many projects (including our own), and is regularly updated. Another particularly useful feature of Jenkins is that it can work with and integrate with many other tools that are used in projects, including Docker and Git. 

Or first step was to ensure that Jenkins was installed on the VM. This entailed setting up Jenkins on the VM and making sure that it was set up correctly (including the Admin setup, the plugins necessary for the project).

The next step was to put in the right credentials which would be used at the Jenkins build and deploy step. This included the Docker credentials via Jenkins GUI configuration so that Jenkins could push the image to the DockerHub repo as needed. We also included in our Jenkinsfile the scripts and the commands needed to log into docker, the directories it needs to access the tests and scripts, as well as the Docker image names, along with the github details and webhook integration to automate this stage of the pipeline. Finally there was a script to run the Kubectl commands for the deployment onto the EKS cluster. 

Successful builds were stored in an artefacts repository in Jenkins. 

![JENKINS BUILD](https://github.com/Jack-Middleton/DevOps-group-project/blob/0c194c6b176ae1f458a2b71b9d07abd1b3ca6cf9/images/Jenkins%20build.png)

## Automated testing with error reports generated

In the application, there were tests files built already, so we used Karma and Maven to run the unit tests for the front and backend respectively. We didn't do the end to end tests due to time constraints and the fact that we already had the application up and running.  

The process of unit testing for the frontend required a few modules to be installed beforehand to be able to run the tests. Nodejs had to be installed which was done using curl to download the executable file and installed with sudo permissions. After that dependencies were installed using npm i. NPM is the node package manager. As Karma outputs the test results on an external browser, Google Chrome was downloaded and installed using wget and sudo apt install. The test was then run using npm run test-headless. The headless command allows the test to run without opening the browser and allows the test to run in the background. This frontend test concluded with a 43/43 pass mark.

![FRONTEND TEST](https://github.com/Jack-Middleton/DevOps-group-project/blob/0c194c6b176ae1f458a2b71b9d07abd1b3ca6cf9/images/Frontend%20Test%20image.png)

For testing the backend a different approach was taken. Since Maven is used here java JDK is needed to run the test. This was a simple sudo apt install openjdk-11-jdk to install. This would then allow the mvnw script to be executed which would then run the test and test all 143 codes.

# Automated deployment

The application was deployed using Kubernetes on an Amazon EKS cluster. Using an EKS cluster had the following advantages: 

* We didn’t need to install, operate, and maintain our own Kubernetes control plane or nodes
* It automatically created a load balancer for us
* It monitors performance and automatically replaces unhealthy instances
* It is easily scalable 

Our EKS cluster was created using Terraform as described above.

Kubernetes (K8S) is a container orchestration tool which is used to automate deployments of containerised applications. We chose to use Kubernetes for the following reasons: 

* It is an open-source free tool 
* The team were already familiar with it
* It works with any containerisation tool which gives a lot of flexibility
* Scales easily
* It automatically manages the pods with minimal human oversight

We installed Kubectl which is a command line tool which allowed us to communicate with the cluster’s API server. 

We created manifests which were used to define the desired state of our cluster. Using manifests gave us a single source of truth for the deployment and also meant that we could repeat or reuse the files for other similar projects. 

The table below shows what was created via the manifests:

Frontend	Pod, Load Balancer Service
Backend 	Pod, Load Balancer Service
Database	Pod, Persistent Volume

The Jenkinsfile then ran a script containing Kubectl commands which applied the images created to the cluster. The application was then accessible via the load-balancer IP address. 

This pipeline can be illustrated with the below diagram. 

INSERT PIPELINE DIAGRAM

# Demonstration of the application 

The deployed application allows a user to input data about pet types and vets and whilst the application is running, the user can see and search the data that has been added. However as stated above, the MVP doesn't persist data so once the window is closed, the data is lost.

!APPLICATION SCREENSHOT](https://github.com/Jack-Middleton/DevOps-group-project/blob/0c194c6b176ae1f458a2b71b9d07abd1b3ca6cf9/images/Application%20screenshot.png)

# Budget

Using Amazon’s own ‘Cost Explorer’ we found that our running costs based on this set up would be ~ £4.96 p/day, this comes to ~ £145.76 p/month to run the instances that had been set-up.

This is relatively expensive so we examined how we could reduce the running costs as follows:

* We can reduce the computing power of our VM’s by resizing to a smaller state, but increasing block size. (Which increases storage available).
* For project purposes we can turn all virtual machines required off at night when they are not being worked on.
* After a review, we noticed that we have the capacity for 34 pods across 2 nodes while we are only using 2 nodes and 6-7 pods. We could drastically reduce our costs by properly utilising the nodes we actually require to manage the application.

# Retrospective

## What went well?

* We worked really well as a team with good communication
* Managed our time properly to the point where we were able to meet the deadline with our MVP
* Distributed tasks according to strengths
* Learnt a lot about the technologies we used

## What went wrong? 
* We had a lot of time spent on addressing the version compatibility issues
* Our VMs kept crashing
* We had issues connecting the front-end to the back-end initially
* Absences in teams due to unforeseen circumstances
* Too many users on one VM which resulted in clashes
* Lack of experience joining the tools together and using Java

## What we would do differently? 
* Start the project with trying to get the app running manually instead of going straight to automation planning
* Be more cautious of what branch we’re working on to avoid merge conflicts later on - useGitHUb
* Be more thorough in our planning of the entire pipeline and spent more time on defining the tasks
* Select hardware that had more than ample specs to handle the workload 
