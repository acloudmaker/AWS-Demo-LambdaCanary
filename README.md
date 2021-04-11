# AWS-Demo-LambdaCanary
AWS Lab Style Step by Step Demonstration, Tested and Working!

## STEPS

1. Login to AWS Console
2. Create Cloud9 environment with any name (e.g. LambdaCanaryDemo), fill in default values and Next Step all the way until Create Environment. Wait until the environment is created, takes ~1-2 minutes
3. Setup SAM by opening a terminal window (left click on green plus sign pn menu tab to see has the option or just press Alt T) and run the serverless bootstrap script as shown below. If eveyrhthing goes well, you should see _SAM CLI, version 1.19.0_ (or some version) output

```
wget https://cicd.serverlessworkshops.io/assets/bootstrap.sh
sh -x bootstrap.sh
sam --version
```

4. In your console browser window, open few more separate tabs to load Lambda, API Gatweway and CloudFormation consoles. You will use it throughout the demo to see progress in respective areas. An easy way to do it is by left clicking on the _Cloud9 icon_ on the Cloud9 IDE top menu and clicking on the _Go To Your Dashboard_ item

5. Initialize SAM project (For the init command input, choose Quickstart, Zip artifact, latest Nodejs runtime, lambda-canary-app as the project name and Hello World example). Then build and deploy the SAM application

```
sam init
cd ~/environment/lambda-canary-app
sam build
sam deploy --guided
```
