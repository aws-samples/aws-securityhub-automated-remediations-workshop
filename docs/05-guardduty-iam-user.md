# Module 5 - Automated Remediations - GuardDuty Event on IAMUser
1. Run the following command:

        ${CLOUDCUSTODIANDOCKERCMD} securityhub-remediations/module5/iam-user-hubfinding-remediate-disable.yml

2.  Verify that the previous command resulted in output containing "Provisioning policy lambda iam-user-hubfinding-remediate-disable"
3.  Optional, but at least read: Next archive any existing sample GuardDuty Findings for the IAM User named GeneratedFindingUserName.  While this is not nessesary when the create-sample-findings command (which is run later in this module) has never been run before, it won't harm anything to run.  And if it's not run and the sample finding has already been generated, then the cloudwatch event needed for this module to function never gets triggered, so we're running it to eliminate sources of potential error.  And if you want to rerun this module, you need to run this command.

        aws guardduty archive-findings \
            --detector-id \
                $(aws guardduty list-detectors --query DetectorIds --output text) \
            --finding-ids \
                $(aws guardduty list-findings \
            --detector-id \
                $(aws guardduty list-detectors --query DetectorIds --output text) \
            --finding-criteria '{"Criterion": {"service.archived": {"Eq":["false"]},"resource.accessKeyDetails.userName": {"Eq":["GeneratedFindingUserName"]}}}' --query 'FindingIds[0]' --output text)

    If you get an error like "InternalServerErrorException", the most likely reason is that there are no findings currently.  Regardless, proceed to the next step.
4.  Archive any existing findings of this type in Security Hub, to be on the safe side.

        aws securityhub update-findings --record-state ARCHIVED --filters '{"ResourceAwsIamAccessKeyUserName":[{"Value": "GeneratedFindingUserName","Comparison":"EQUALS"}]}'

5.  Run the following command to validate that the Access Keys status is currently active:

        aws iam list-access-keys --user-name GeneratedFindingUserName

6. Run the following command, which creates a sample finding in GuardDuty, which automatically get imported into SecurityHub, which is an finding type ['UnauthorizedAccess:IAMUser/MaliciousIPCaller'](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_unauthorized.html#unauthorized5) on an IAMUser named GeneratedFindingUserName, which was created by cloudformation script in module 1.

        aws guardduty create-sample-findings --detector-id `aws guardduty list-detectors --query DetectorIds --output text` --finding-types 'UnauthorizedAccess:IAMUser/MaliciousIPCaller'

7.  First, validate that Guard Duty generated the sample finding by going to the Guard Duty Console and look for the finding type "UnauthorizedAccess:IAMUser/MaliciousIPCaller"
8.  Next, goto the Security Hub console and look the finding Title = "API GeneratedFindingAPIName was invoked from a known malicious IP address" however expect to need to wait for 2-5 minutes for it to appear.
9.  Next validate the execution of the automated remediation by looking within CloudWatch Logs, remember the LogGroup pattern of /aws/lambda/custodian-$(name of the cloud custodian policy) or in this case specifically /aws/lambda/custodian-iam-user-hubfinding-remediate-disable.
    You are looking a lines containing "policy:iam-user-hubfinding-remediate-disable invoking action:userremoveaccesskey resources:1" followed by a line containing "metric:ApiCalls Count:2 policy:iam-user-hubfinding-remediate-disable restype:iam-user", if they don't appear will need to troubleshoot using the logs.
10.  Validate that the Access Keys were actually removed from the user by running the following command:

        aws iam list-access-keys --user-name GeneratedFindingUserName

11. Evaluate the output by looking for "Status"="Inactive"
12. You have completed this module, please proceed to the next module.
