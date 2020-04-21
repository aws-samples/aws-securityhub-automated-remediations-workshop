# Module 4 - Automated Remediations - Vulnerability Event on EC2 Instance with a High Risk Configuration
1.  Run the following command, which invokes Cloud Custodian to run a policy named [ec2-public-ingress-hubfinding](https://github.com/FireballDWF/securityhub-remediations/blob/master/module4/ec2-public-ingress-hubfinding.yml) which filters for a high risk configuation (Details TODO).

        ${CLOUDCUSTODIANDOCKERCMD} securityhub-remediations/module4/ec2-public-ingress-hubfinding.yml

2.  Run the following command to trigger an finding event in Security Hub on the with the resource being the RemediationTestTarget instance.

        ${CLOUDCUSTODIANDOCKERCMD} securityhub-remediations/module1/force-vulnerability-finding.yml

3.  Review the CloudWatch Log to observe that actions listed in the policy were invoked, and you can verify by using the console to view that the instance doesn't have an IAM Profile associated anymore and that a Snapshot was taken.
4.  Now run the following command to re-associate the InstanceProfile so the instance is ready for the next module.

        aws ec2 associate-iam-instance-profile --iam-instance-profile Name=SecurityHubRemediationWorkshopTestTarget --instance-id $(aws ec2 describe-instances --filters "Name=tag:Name,Values=RemediationTestTarget" --query Reservations[*].Instances[*].[InstanceId] --output text)

5.  Review module4/ec2-public-ingress.yml observing that the lack of a "mode" section, compared to the policy deployed earlier in the module, means it can be run anytime from a CLI to find the risky configuration without requiring a vulnerability event.
6.  You have completed this module, please proceed to the next module.
