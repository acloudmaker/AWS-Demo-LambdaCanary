# AWS-Demo-LambdaCanary
AWS Lab Style Step by Step Demonstration, Tested and Working!
This has a total of 5 parts.  
1. [Part 1 - Deploying Lambda With SAM](#part-1---deploying-lambda-with-sam)
2. [Part 2 - CI/CD Pipeline Using CodePipeline](#part-2---cicd-pipeline-using-codepipeline)
3. [Part 3 - CDK Installation and Building the Pipeline](#part-3---cdk-installation-and-building-the-pipeline)
4. [Part 4 - Canary Deployment](#part-4---canary-deployment)
5. [Part 5 - Canary Deployment Failure and Rollback Testing](#part-5---canary-deployment-failure-and-rollback-testing)

## PARTS and STEPS

### Part 1 - Deploying Lambda With SAM
1. Login to AWS Console

2. Create Cloud9 environment with any name (e.g. LambdaCanaryDemo), fill in default values and Next Step all the way until Create Environment. Wait until the environment is created, takes ~1-2 minutes


3. Setup SAM by opening a terminal window (left click on green plus sign on menu tab to see the option or just press Alt T) and run the serverless bootstrap script as shown below. If eveyrhthing goes well, you should see _SAM CLI, version 1.19.0_ (or some version) output

```
wget https://cicd.serverlessworkshops.io/assets/bootstrap.sh
sh -x bootstrap.sh
sam --version
```

4. Optionally, in your console browser window, open few more separate tabs to load Lambda, API Gatweway, CloudFormation and CodeCommit consoles. You will use them throughout the demo to see progress in respective areas. An easy way to open a new service console tab is by left clicking on the _Cloud9 icon_ on the Cloud9 IDE top menu and clicking on the _Go To Your Dashboard_ item and opening each service console in sequence

5. In the terminal window, initialize SAM project (for the init command input, choose Quickstart, Zip artifact, latest Nodejs runtime, lambda-canary-app as the project name and Hello World template example). At this point you should have _~/environment/lambda-canary-app/hello-world/app.js_ code file present and you are free to leave the _message_ as is or modify to something of your liking. We are trying to keep things simple using the classic Hello World example template. Objective here is to test the canary deployment, not Lambda

```
sam init
```

6. Then build and deploy the SAM application. For the deploy input, choose _lambda-canary-app_ as the name of the Stack and everything else is default and _Y_ for all questions including deploying the changeset

```
cd ~/environment/lambda-canary-app
sam build
sam deploy --guided
```

7. Open a new broswer tab and load the API endpoint URL (looks something like _https://3dixbr6ak7.execute-api.us-east-1.amazonaws.com/Prod/hello/_) or just click on the URL from your terminal window output (either in _open_ mode to open in a browser tab or _open in preview_ mode to open in Cloud9 IDE). You should see your typed message in _app.js_ above, similar to _{"message":"hello world"}_ from the Lambda function. **Congratulations!!**. You've successfully created a Lambda function using SAM, CloudFormation, API Gateway and Lamda with just few clicks. Now it is time for Part 2!

### Part 2 - CI/CD Pipeline Using CodePipeline

8. Create the CI/CD Pipeline, starting with CodeCommit

```
cd ~/environment/lambda-canary-app
aws codecommit create-repository --repository-name lambda-canary-app

```

9. Append the following two lines to .gitignore (file should exist already) using any editor

```
vim .gitignore
# Append the following two lines, save and exit
.aws-sam/
packaged.yaml
```
10. Commit the repo files to CodeCommit

```
cd ~/environment/lambda-canary-app
git config --global user.name "YOUR-NAME"
git config --global user.email "YOUR-EMAIL"
git init
git add .
git commit -m "Initial commit of lambda-canary-app repo"
git push -u origin master
```
11. If error messages like _fatal: 'origin' does not appear to be a git repository_ or _fatal: Could not read from remote repository._ appear, add git remote origin URL with the following command. Otherwise skip this step. Make sure to grab your git codecommit URL depending on your region. You can do it by copying the HTTPS link from the CodeCommit console (Navigation path: Developer Tools > CodeCommit > Repositories)


```
git remote add origin https://git-codecommit.us-east-2.amazonaws.com/v1/repos/lambda-canary-app
```

12. If git push went through successfully, in the CodeCommit console window tab that you had opened earlier, verify the codecommit push result and the contents inside repository _lambda-canary-app_. If all looks good, you've successfully completed Part 2 and ready for Part 3

### Part 3 - CDK Installation and Building the Pipeline
13. Build pipeline using CDK, starting with the CDK installation

```
npm uninstall -g aws-cdk
npm install -g aws-cdk --force
cd ~/environment/lambda-canary-app
mkdir pipeline
cd pipeline
cdk init --language typescript
npm install --save @aws-cdk/aws-codedeploy @aws-cdk/aws-codebuild
npm install --save @aws-cdk/aws-codecommit @aws-cdk/aws-codepipeline-actions
```

14. Edit the _pipeline.ts_ file inside the _bin_ directory. It is the entry point to the CDK project, and change the name of the stack to _lambda-canary-app-cicd_ in the line saying _new PipelineStack(app,_

```
cd bin
vim pipeline.ts
# change the name of the stack to lambda-canary-app-cicd inside the file, save and exit
```

15. Build Pipeline as Code using CDK

```
cd ~/environment/lambda-canary-app/pipeline
npm run build
cdk deploy
```

16. Check on CloudFormation console and verify that a new CloudFormation stack _lambda-canary-app-cicd_ was created, but because the CDK project is empty, the only resource that was created was an AWS::CDK::Metadata. On the CloudFormation Console, review the new stack and the metadata under the Resources tab

17. Create the artifact bucket on S3 by copying the Edit the pipeline-stack file with .ts extension. But before that you have to git clone the AWS-Demo-LambdaCanary repository that contains yours truly README.md instrcutions!

```
cd ~
git clone https://github.com/acloudmaker/AWS-Demo-LambdaCanary.git
export SRC=~/environment/AWS-Demo-LambdaCanary
echo $SRC
ls -al $SRC
# Make sure SRC environment var is set and you are able to list the directory before proceeding further
# You will use $SRC reference a lot from here on to copy code files
cd ~/environment/lambda-canary-app/pipeline/lib
cp $SRC/pipeline-stack.ts.artifact pipeline-stack.ts
```
18. Build and deploy the project like earlier

```
cd ~/environment/lambda-canary-app/pipeline
npm run build
cdk deploy
```

19. You should see on the S3 console a bucket named like _aws-sam-cli-managed-default-samclisourcebucket-ukygkp8eacjr_ with a _lambda-canary-app/_ folder. Next add the source stage to pipeline. This stage is in charge of triggering the pipeline based on new code changes (i.e. git push or pull requests). AWS CodeCommit is used as the source provider here, but CodePipeline also supports S3, GitHub and Amazon ECR as source providers.

```
cd ~/environment/lambda-canary-app/pipeline/lib
cp $SRC/pipeline-stack.ts.source-stage pipeline-stack.ts
# No build necessary at this stage
```

20. Add the build stage to pipeline. The Build Stage is where the Serverless application is built and packaged by SAM. AWS CodeBuild is used as the Build provider for tthe pipeline but CodePipeline also supports other providers like Jenkins, TeamCity or CloudBees

```
cd ~/environment/lambda-canary-app/pipeline/lib
cp $SRC/pipeline-stack.ts.build-stage pipeline-stack.ts
```
21. Build and deploy the project like earlier

```
cd ~/environment/lambda-canary-app/pipeline
npm run build
cdk deploy
```

22. Navigate to the AWS CodePipeline Console and check newly created pipeline! The Build step should have failed which is expected because no commands are specified yet to run during the build, so AWS CodeBuild doesn’t know how to build the Serverless application.

23. Copy the buildspec.yml file to the root (top level) of the lambda-canary-app directory

```
cd ~/environment/lambda-canary-app
# Make sure buildspec.yml exists in this directory
cp $SRC/buildspec.yml .
git add .
git commit -m "Added buildspec.yml"
git push
```

24. Navigate to CodePipeline console again, and wait for it to trigger automatically. This time the build will succeed

25. Add the deploy stage to the pipelne. The Deploy Stage is where the SAM application and all its resources are created in an AWS account. The most common way to do this is by using CloudFormation ChangeSets to deploy. This means that this stage will have 2 actions: the CreateChangeSet and the ExecuteChangeSet.

```
cd ~/environment/lambda-canary-app/pipeline/lib
cp $SRC/pipeline-stack.ts.deploy-stage pipeline-stack.ts
```

26. Deploy the pipeline

```
cd ~/environment/lambda-canary-app/pipeline
npm run build
cdk deploy
```

27. Navigate to the pipeline on CodePipelie console and see that the Deploy stage has been added. It is grayed out because it hasn’t been triggered yet. Trigger a new run of the pipeline manually by clicking the Release Change buttton.

28. Let the pipline run every stage. After it finishes and if everything looks green, commit and push the code to _lambda-canary-app_ source repository. **Congratulations!** You have successfully completed creation of a CI/CD pipeline for a Serverless application using SAM and CDK!

```
cd ~/environment/lambda-canary-app
git add .
git commit -m "CI/CD Pipeline definition"
git push
```

### Part 4 - Canary Deployment
29. Copy the canary enabled _template.yaml_ to _lambda-canary-app_ directory and validate the template. For this canary demo, Canary10Percent5Minutes strategy will be used, which means that traffic is shifted in two increments. In the first increment, only 10% of the traffic is shifted to the new Lambda version, and after 5 minutes, the remaining 90% is shifted. CodeDeploy allows other types of deployment, e.g. CanaryXPercentYMinutes, LinearXPercentEveryYMinutes and AllAtOnce. The Linear strategy means that traffic is shifted in equal increments with an equal number of time interval between each increment.

```
cd ~/environment/lambda-canary-app
cp $SRC/template.yaml.canary-config template.yaml
sam validate
```

30. Trigger a canary deployment by making some changes to Lambda function code as well as the corresponding unit testing code. Not changing the unit testing code will fail the build stage.

```
cd ~/environment/lambda-canary-app
# To be safe, copy good versions of code
export SRC=~/environment/AWS-Demo-LambdaCanary
echo $SRC
ls -al $SRC
cd ~/environment/lambda-canary-app/hello-world
cp $SRC/app.js app.js
cp $SRC/test-handler.js tests/unit/test-handler.js
vim app.js tests/unit/test-handler.js
# Change the greeting message to something like "Hello AWS Community!" in both files. Save and exit and then push to CodeCommit
cd ~/environment/lambda-canary-app
git add .
git commit -m "Canary deployments with SAM"
git push
```

31. Navigate to the AWS CodeDeploy console, click on the Deployments link on the left menu, then click on the Deployment ID in progress to see the details. The deployment status should show 10% of the traffic shifted to the new version Replacement (aka The Canary) and the remaining percentage pointing to Original. After 5 minutes since we specified Canary10Percent5Minutes, the remaining traffic should shifted to the Replacement

### Part 5 - Canary Deployment Failure and Rollback Testing

32. Define a CloudWatch Alarm to monitor Canary deployments and this helps to configure CodeDeploy to automatically roll back the deployment if a specified CloudWatch metric has breached the alarm threshold. Common metrics to monitor are Lambda Invocation errors or Invocation Duration (latency), for example.

```
cd ~/environment/lambda-canary-app
cp $SRC/template.yaml.cloudwatch-alarm-config template.yaml
sam validate
```

35. Monitoring the health of canary allows CodeDeploy to make a decision to whether a rollback is needed or not. If any of the CloudWatch Alarms specified gets to ALARM status, CodeDeploy rollsback the deployment automatically. The change below intentionally breaks the Lambda function on purpose so that the CanaryErrorsAlarm gets triggered during deployment.

```
cd ~/environment/lambda-canary-app/hello-world
cp $SRC/app.js.error app.js
cp $SRC/test-handler.js.error tests/unit/test-handler.js
cd ~/environment/lambda-canary-app
git add .
git commit -m "Breaking the lambda function on purpose"
git push
```

36. Again, wait for the Pipeline to reach the deployment phase (ExecuteChangeSet). It should turn blue when it begins. While the deployment is running, generate traffic to the new Lambda function to make it fail and trigger the CloudWatch Alarm. Note that in a real production environment, users will generate organic traffic to the canary function, so the following is not necesary but it is used here for simulation. Run the following command to invoke the Lambda function

```
cd ~/environment/lambda-canary-app
cp $SRC/cli-lambda-invoke.sh .
sh -x cli-lambda-invoke.sh
```
37. Note that, during deployment, only 10% of the traffic will be routed to the new version. So, keep on invoking the above lambda many times. 1 out of 10 invocations should trigger the new broken lambda, which is what causes a rollback. The following command invokes the function 15 times in a loop. 

```
cd ~/environment/lambda-canary-app
cp $SRC/cli-lambda-invoke-loop.sh .
sh -x cli-lambda-invoke-loop.sh
```

38. Navigate to the AWS CodeDeploy Console and go into the deployment In-Progress to view its details. After a few minutes, CodeDeploy will detect that the CanaryErrorsAlarm has triggered and it will start rolling back the deployment with an error message saying _the deployment is cancelled due to an abort request_. The screen will show, unlike a successful canary deployment, Original traffic at 100% and Replacement traffic at 0%. 

39. **CONGRAULATIONS** for successfully completing all the objectives of this demo!!

40. Please [Follow this workshop if you want to create a SAM application with Java](https://cicd.serverlessworkshops.io/java.html) just like the implementation here done using Node.js. Thank you for following. 
