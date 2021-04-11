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

5. In the terminal window, initialize SAM project (for the init command input, choose Quickstart, Zip artifact, latest Nodejs runtime, lambda-canary-app as the project name and Hello World example). At this point you should have _~/environment/lambda-canary-app/hello-world/app.js_ code file present and you are free to leave the _message_ as is or modify to something of your liking. After all it is the classic Hello World example. Objective here is to test the canary deployment, not Lambda

```
sam init
```

6. Then build and deploy the SAM application. For the deloy input, choose _lambda-canary-app_ as the name of the Stack and everything else is default and _Y_ for all questions including deploying the changeset

```
cd ~/environment/lambda-canary-app
sam build
sam deploy --guided
```

7. Open a new broswer tab and load the API endpoint URL (looks something like _https://3dixbr6ak7.execute-api.us-east-1.amazonaws.com/Prod/hello/_) or just click on the URL from your terminal window output. You should see your message similar to _{"message":"hello world!"}_ from the Lambda function. **Congratulations!!**. You've successfully created a Lambda function using SAM, CloudFormation, API Gateway and Lamda with just few clicks
