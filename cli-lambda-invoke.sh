sudo yum install -y jq
aws lambda invoke --function-name \
	$(aws lambda list-functions | jq -r -c '.Functions[] | select( .FunctionName | contains("sam-app-HelloWorldFunction")).FunctionName'):live \
	--payload '{}' \
	response.json
