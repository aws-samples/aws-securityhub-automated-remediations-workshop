# Module 2 - Automated Remediations - GuardDuty DNS Event on EC2 Instance
1.  Run the following command which runs a policy named [ec2-sechub-remediate-severity-with-findings](https://github.com/aws-samples/aws-securityhub-automated-remediations-workshop/blob/master/module2/ec2-sechub-remediate-severity-with-findings.yml) which instructs Cloud Custodian to dynamically generate and deploy a lambda, which will be invoked when [SecurityHub generates a Cloudwatch Event](https://docs.aws.amazon.com/securityhub/latest/userguide/securityhub-cloudwatch-events.html) when sent a finding. In this module, the finding will be triggered when GuardDuty generates a finding, and the severity of the is greater than or equal to 31, and the EC2 instance has any vulnerability previously reported to SecurityHub

        ${CLOUDCUSTODIANDOCKERCMD} aws-securityhub-automated-remediations-workshop/module2/ec2-sechub-remediate-severity-with-findings.yml

2.  Next run the following command which leverages [Systems Manager's Run Command](https://docs.aws.amazon.com/systems-manager/latest/userguide/execute-remote-commands.html) to run an "nslookup" command on the ec2 instance tag:Name RemediationTestTarget where it's looking up a dns name which [GuardDuty will detect as Command and Control activity](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_backdoor.html#backdoor7)

        aws ssm send-command --document-name AWS-RunShellScript --parameters commands=["nslookup guarddutyc2activityb.com"] --targets "Key=tag:Name,Values=RemediationTestTarget" --comment "Force GuardDutyFinding" --cloud-watch-output-config CloudWatchLogGroupName=/workshop/SecurityHubRemediationsWorkshop,CloudWatchOutputEnabled=true

3.  As it can take a long time (more than 20 minutes often around 2 hours) for GuardDuty to generate a DNS based finding, please proceed to the next module, then come back to the next review step later.
4.  Review Cloudwatch LogGroup "/aws/lambda/custodian-ec2-sechub-remediate-severity-with-findings" to see that it did a Snapshot.
