sudo yum install -y jq
aws lambda invoke --function-name \
	$(aws lambda list-functions | jq -r -c '.Functions[] | select( .FunctionName | contains("lambda-canary-app-HelloWorldFunction")).FunctionName'):live \
	--payload '{}' \
	response.json
