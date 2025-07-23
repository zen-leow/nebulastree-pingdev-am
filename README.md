# Creating a local PingAM Environment using Docker Compose
## Overview
The purpose of this project is to provide a quick deployment method to setup a PingAM (formerly ForgeRock Access Management) environment for anyone developing applications that utilises PingAM for authentication. For example, building an Android app and you want to test out the SDK provided by PingIdentity. Or you wish to experiment with the different REST APIs available from PingAM. I'm using AM 8.0.1 and DS 8.0.0 which are the latest at the time of this writing. Hope this will be helpful for you.

## How this differs from ForgeOps
This project is not to be confused with _forgeops_ although parts of the project uses it as reference. ForgeOps provides a means to create the full Identity Platform (AM, IDM, DS, Platform UIs) using Kubernetes. Even for local deployment, you are going to need Minikube... For the uninitiated, this can be rather daunting. 

Over here we are only focusing on creating 1 x AM container and using 1 x DS container to be the config store, user store and CTS. I couldn't use the docker images provided by PingIdentity as they are very tightly coupled to ForgeOps way of doing things so I create these from scratch while referencing some of the scripts forgeops uses and stripped out everything I don't need. This is by no means a production ready setup but it's good enough for a local development environment.

The AM in ForgeOps uses File Based Configurations (FBC). This project uses the DS container as the configuration store. Exporting configurations to deploy elsewhere is not the focus of this project though you can check out the official documentations and it should work fine.

## Preparations
Before you run docker compose on this, you need to have some pre-requisites sorted out. This should work on Windows or Linux machines just fine.
1. Docker Desktop - That should cover `docker compose` too.
2. Git - This is actually optional but I prefer using Git Bash that comes with it over the usual Windows Command Prompt.
3. A Forgerock Backstage account (it's free!) https://backstage.forgerock.com/
4. Download PingAM's WAR file and Amster zip file. https://backstage.forgerock.com/downloads/browse/am/featured
   - You need to login with your registered account to initiate the download.

Note: You don't have to download PingDS from backstage as it is not going to work OOTB. I've done the necessary changes and created a custom PingDS base image which is then pushed to ghcr.io. The Docker file in this repo will pull the image from there and setup config store, user store and CTS automatically.
  
## The Short Story
1. Either clone or download all the files here as zip. Maintain the folder structure as is without change.
2. Unzip the files to your desired working directory.
3. Place the downloaded AM war and Amster zip file into path-to-working-dir/am/build.
4. Edit the `.env` file to update the war file name and amster file name if it is not the same.
5. Add this to your hosts file `127.0.0.1 auth.pingdev.local`
6. Open a command prompt and go to your working directory
7. Run `docker compose build`
8. Once it's done, run `docker compose up -d`
9. You can review the AM container's logs to wait for it to be ready.
10. First time startup will take a bit longer as Amster needs to install the base configurations.
11. If there's no startup error AND you see `Open a browser and load https://auth.pingdev.local:8443/am`, then it's ready.
12. Load `https://auth.pingdev.local:8443/am` on your browser, accept the Security risk thrown by your browser (since we are using self signed certs here).
13. Login with Username: amadmin / Password: password
14. Have fun.

## The Long Story
This is where I'll talk about how the 2 containers work together, what the settings in `docker-compose.yml` and `.env` mean and how to change things, etc...
To be updated later...
