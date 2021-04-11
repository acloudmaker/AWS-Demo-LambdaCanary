# AWS-Demo-LambdaCanary
AWS Lab Style Step by Step Demonstration, Tested and Working!

## STEPS

1. Login to AWS Console

2. Create Cloud9 environment with any name (e.g. LambdaCanaryDemo), fill in default values and Next Step all the way until Create Environment. Wait until the environment is created, takes ~1-2 minutes.

3. Setup SAM by opening a terminal window (left click on green plus sign pn menu tab to see has the option or just press Alt T) and run the serverless bootstrap script as shown below

```
wget https://cicd.serverlessworkshops.io/assets/bootstrap.sh
sh -x bootstrap.sh
sam --version
```
