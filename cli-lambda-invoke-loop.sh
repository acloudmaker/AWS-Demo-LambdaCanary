sudo yum install -y jq

counter=1
while [ $counter -le 15 ]
do
  aws lambda invoke --function-name \
  $(aws lambda list-functions | jq -r -c '.Functions[] | select( .FunctionName | contains("lambda-canary-app-HelloWorldFunction")).FunctionName'):live \
  --payload '{}' \
  response.json
  sleep 1
  ((counter++))
done
