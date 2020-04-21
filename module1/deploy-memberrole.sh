
aws2 cloudformation update-stack-set --stack-set-name CloudCustodianMemberRole --template-body file://cloudcustodian-memberrole.yml  --capabilities CAPABILITY_NAMED_IAM --description "Deploy CloudCustodianMember role to member accounts" --administration-role-arn arn:aws:iam::$MASTERACCOUNT:role/CodeBuildStackSetAdmin --execution-role-name CodeBuildStackSetExecution  --parameters ParameterKey=MasterAccountId,ParameterValue=$MASTERACCOUNT
aws2 cloudformation update-stack-instances --stack-set-name CloudCustodianMemberRole --accounts $MEMBERACCOUNTS --regions us-east-1
