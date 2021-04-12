# AWS-Demo-LambdaCanary
AWS Lab Style Step by Step Demonstration, Tested and Working!

## PARTS and STEPS

### Part 1 - Lambda Function
1. Login to AWS Console

2. Create Cloud9 environment with any name (e.g. LambdaCanaryDemo), fill in default values and Next Step all the way until Create Environment. Wait until the environment is created, takes ~1-2 minutes


3. Setup SAM by opening a terminal window (left click on green plus sign pn menu tab to see has the option or just press Alt T) and run the serverless bootstrap script as shown below. If eveyrhthing goes well, you should see _SAM CLI, version 1.19.0_ (or some version) output

```
wget https://cicd.serverlessworkshops.io/assets/bootstrap.sh
sh -x bootstrap.sh
sam --version
```

4. In your console browser window, open few more separate tabs to load Lambda, API Gatweway, CloudFormation and CodeCommit consoles. You will use them throughout the demo to see progress in respective areas. An easy way to open a new service console tab is by left clicking on the _Cloud9 icon_ on the Cloud9 IDE top menu and clicking on the _Go To Your Dashboard_ item and opening thr service console there

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

7. Open a new broswer tab and load the API endpoint URL (looks something like _https://3dixbr6ak7.execute-api.us-east-1.amazonaws.com/Prod/hello/_) or just click on the URL from your terminal window output. You should see your message similar to _{"message":"hello world!"}_ from the Lambda function. **Congratulations!!**. You've successfully created a Lambda function using SAM, CloudFormation, API Gateway and Lamda with just few clicks. Now it is time for Part 2!

### Part 2 - CI/CD Pipeline

8. Create the CI/CD Pipeline, starting with CodeCommit

```
cd ~/environment/lambda-canary-app
aws codecommit create-repository --repository-name lambda-canary-app

```

9. Append the following two lines to .gitignore (file should exist already) using any editor

```
vim .gitignore
# Append the following two lines
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
11. If error messages like _fatal: 'origin' does not appear to be a git repository_ or _fatal: Could not read from remote repository._ appear, reset git remote origin URL with the following command. Otherwise skip this step

```
git remote set-url origin  https://git-codecommit.us-east-1.amazonaws.com/v1/repos/lambda-canary-app
```

12. If git push went through successfully, in the CodeCommit console window tab that you had opened earlier, verify the codecommit push result and the contents inside repository _lambda-canary-app_. If all looks good, proceed to Part 3

### Part 3 - CDK Installation
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

17. Create the artifact bucket on S3 by copying the Edit the pipeline-stack file with .ts extension

```
$ cd ~/environment/lambda-canary-app/lib
$ cp pipeline-stack.ts.artifact pipeline-stack.ts
```
18. Build and deploy the project like earlier

```
npm run build
cdk deploy
```

19. Add the source stage to pipeline. This stage is in charge of triggering the pipeline based on new code changes (i.e. git push or pull requests). AWS CodeCommit is used as the source provider here, but CodePipeline also supports S3, GitHub and Amazon ECR as source providers.

```
$ cd ~/environment/lambda-canary-app/lib
$ cp pipeline-stack.ts.source-stage pipeline-stack.ts
# No build necessary at this stage
```

20. Add the build stage to pipeline. The Build Stage is where the Serverless application is built and packaged by SAM. AWS CodeBuild is used as the Build provider for tthe pipeline but CodePipeline also supports other providers like Jenkins, TeamCity or CloudBees

```
$ cd ~/environment/lambda-canary-app/lib
$ cp pipeline-stack.ts.build-stage pipeline-stack.ts
```
21. Build and deploy the project like earlier

```
npm run build
cdk deploy
```

22. Navigate to the AWS CodePipeline Console and check newly created pipeline! The Build step should have failed which is expected because no commands are specified yet to run during the build, so AWS CodeBuild doesn’t know how to build the Serverless application.

23. Copy the buildspec.yml file to the root (top level) of the lambda-canary-app directory

```
cd ~/environment/lambda-canary-app
# Make sure buildspec.yml exists in this directory
git add .
git commit -m "Added buildspec.yml"
git push
```

24. Navigate to CodePipeline console again, and wait for it to trigger automatically. This time the build will succeed

25. Add the deploy stage to the pipelne. The Deploy Stage is where the SAM application and all its resources are created in an AWS account. The most common way to do this is by using CloudFormation ChangeSets to deploy. This means that this stage will have 2 actions: the CreateChangeSet and the ExecuteChangeSet.

```
$ cd ~/environment/lambda-canary-app/lib
$ cp pipeline-stack.ts.deploy-stage pipeline-stack.ts

26. Deploy the pipeline

```
cd ~/environment/lambda-canary-app/pipeline
npm run build
cdk deploy
```

27. Navigate to the pipeline on CodePipelie console and see that the Deploy stage has been added. It is grayed out because it hasn’t been triggered yet. Trigger a new run of the pipeline manually by clicking the Release Change buttton.

28. Let the pipline run every stage. After it finishes and if everything looks green, commit and push the code to _lambda-canary-app_ source repository. **Congratulations!** You have successfully completed creation of a CI/CD pipeline for a Serverless application using SAM and CDK!

```
git add .
git commit -m "CI/CD Pipeline definition"
git push
```
