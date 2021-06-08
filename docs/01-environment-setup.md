# Module 1: Environment build and configuration

To Get started with this workshop as part of the an AWS Event where Event Engine is being used, please follow the steps directly following, otherwise skip down to the section labeled ["Getting Started using your own account"](#getting-started-using-your-own-account).

## Getting Started at AWS event where the Event Engine is being used

1.  Open https://dashboard.eventengine.run/login in a new Tab or Window to access the Event Engine Dashboard
2.  Enter the event hash code that you were provided and click Proceed.
3.  Look for a section of the page labeled "Event Engine Team Role" then click "Open Console" button within the Login Link section
4.  Make sure you are in the correct region.
5.  Skip the ["Getting started using your own account"](#getting-started-using-your-own-account) and continue with the ["Manual Setup Steps"](#manual-setup-steps)

## Getting Started using your own account:
1.  In order to complete this workshop, you'll need a valid, usable AWS Account. Use a personal account or create a new AWS account to ensure you have the necessary access and that you do not accidentally modify corporate resources. Do not use an AWS account from the company you work for unless you have explicit approval to conduct security related training exercises in it. We strongly recommend that you use a non-production AWS account for this workshop such as a training, sandbox or personal account. Attempts by multiple participants to use the same account for this workshop will fail, due to the deployment of Named IAM Roles and Users.
2.  You will incur charges for the AWS resources used in this workshop.  The charges for some of the resources may be covered through the [AWS Free Tier](https://aws.amazon.com/free/). The demo uses free tier choices wherever possible.
3.  You must run this workshop in a region support by [AWS Cloud9](https://docs.aws.amazon.com/general/latest/gr/cloud9.html#cloud9_region)
4.  If you choose to use an existing VPC, it needs to have connectivity thru an IGW to reach AWS public endpoints as some of the services used do not yet support VPC Endpoints.
5.  Now we need to download a copy of the CloudFormation template for this Workshop.  If you don't have the program wget, use any other method you are comfortable with, such as curl or a browser.

        wget https://raw.githubusercontent.com/aws-samples/aws-securityhub-automated-remediations-workshop/master/module1/securityhub-remediations-workshop.yml

6. Next we start to to create the cloudformation stack for the workshop, starting by opening the AWS Console, navigate to Cloudformation, click on the "Create stack" button, select the "With new resources (standard)" option, then in the "Specify template" section, click "Upload a template file", then click "Choose file", and when the File Dialog window pops up, select the file downloaded in the prior step.
7. Click Next.
8. Enter in a Stack name, for example "SecurityHubRemediations".
9. Change the value of "EventEngine" to False.
9. Change the value of VpcId to "CreateNew", unless you have a good reason to want to use an existing VPC and if so, enter the VpcId instead
10. Change the value of EnableCloudtrail to False, unless you don't already have it enabled.
9. Click the "Next" button.
9. On the "Configure stack options" page, Click the "Next" button.
9. On the "Review" page, click the checkbox to the left of "I acknowledge that AWS Cloudformation might create IAM resources with custom names", as it will.
9. Click "Create Stack"
9. Wait until the stack if finished creating before starting the next step as the Cloud9 environment needs to be enabled before it will work correctly
10. Enable a Cloudtrail in the region, if you don't then module6 won't work.

## Manual Setup Steps
1.  Open the Cloud9 IDE which provides the ability to review files and execute commands in a browser based terminal window.  Starting from the main AWS Management Console, within the "Search for Services..." textbox at the top, type "Cloud9" then hit Enter.
2.  Now click the "Open IDE" button.
3.  In the bottom part of the browser tab which opens up, look for a tab with a label starting with "bash", where the window contents contain "~/environment $".  This is the browser based terminal session you'll use for the rest of the workshop for any command line steps.

4.  You need to have GuardDuty enabled on the account for module 2 and 5 to work, if not yet then either run the following command or follow the [steps to enable on the console](https://docs.aws.amazon.com/guardduty/latest/ug/guardduty_settingup.html#guardduty_enable-gd)

        aws guardduty create-detector --enable

5.  Run the following command to enable SecurityHub in the account, unless you are using your own account and know that it's already enabled. If you have full unresticted Admin Access, and get an error, then the most likely reason is that it is already enabled.

        aws securityhub enable-security-hub

5.  Run the following command to enable the integration of Cloud Custodian with SecurityHub, unless you are using your own account and know that it's already enabled. If you have full unresticted Admin Access, and get an error, then the most likely reason is that it is already enabled.  If using a region other than us-west-2, replace the us-west-2 part of the arn with the region you are using.

        aws securityhub enable-import-findings-for-product --product-arn "arn:aws:securityhub:us-west-2::product/cloud-custodian/cloud-custodian"

6.  The next step is to get a copy of the files required for this workshop by cloning the workshop's github repo.

        git clone --single-branch --branch master https://github.com/aws-samples/aws-securityhub-automated-remediations-workshop.git

7.  Next step is to pull down the latest version of the Cloud Custodian docker container image and setup the repeative part of the command line

        export SECHUBWORKSHOP_CONTAINER=cloudcustodian/c7n
        docker pull ${SECHUBWORKSHOP_CONTAINER}
        export CLOUDCUSTODIANDOCKERCMD="docker run -it --rm --cap-drop ALL -v /home/ec2-user/environment/aws-securityhub-automated-remediations-workshop:/home/custodian/aws-securityhub-automated-remediations-workshop:ro -v /home/ec2-user/.aws:/home/custodian/.aws:rw ${SECHUBWORKSHOP_CONTAINER} run --cache-period 0 -s /tmp -c"

8.  This step tests the environment by invoking a Cloud Custodian Policy which reports that an ec2 instance has a vulnerability.

        ${CLOUDCUSTODIANDOCKERCMD} aws-securityhub-automated-remediations-workshop/module1/force-vulnerability-finding.yml

    You should expect to see 2 output lines, one containing "count:1" and another containing "resources:1", similar to the following output.  If you get an error on "batch-import-findings" then it means SecurityHub has not been enabled.  Example output is from us-east-1, however your results should indicate the region being used for the workshop event.

        2019-08-11 16:33:57,326: custodian.policy:INFO policy:ec2-force-vulnerabilities resource:ec2 region:us-east-1 count:1 time:0.00
        2019-08-11 16:33:57,787: custodian.policy:INFO policy:ec2-force-vulnerabilities action:instancefinding resources:1 execution_time:0.46

Here is a breakdown of the command you just ran:

| Command Line Component | Description |
| --------- | ------------ |
| docker run | [Run](https://docs.docker.com/engine/reference/run/) a [docker](https://docs.docker.com/engine/reference/commandline/cli/) container |
| -it | [interactive/foreground mode](https://docs.docker.com/engine/reference/run/#foreground) |
| --rm | [clean up docker container when container exits](https://docs.docker.com/engine/reference/run/#clean-up----rm) |
| --cap-drop ALL | Drop all Linux kernel capabilities as recommended in Rule #3 of the [Docker Security Cheat Sheet](https://github.com/OWASP/CheatSheetSeries/blob/master/cheatsheets/Docker_Security_Cheat_Sheet.md) |
| -v /home/ec2-user/environment/aws-securityhub-automated-remediations-workshop:/home/custodian/aws-securityhub-automated-remediations-workshop:ro|map the files for the workshop into the container so the cloud custodian policies are available insider the container. volume is mapped in ReadOnly mode |
| -v /home/ec2-user/.aws:/home/custodian/.aws:ro | maps the [aws cli configuration files](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html) into the container in read-only mode.  Cloud Custodian uses the same configuration files, as both use the [boto3 Python SDK](https://boto3.amazonaws.com/v1/documentation/api/latest/index.html) and sets the region |
| ${SECHUBWORKSHOP_CONTAINER} | evaluates to cloudcustodian/c7n which is the docker container image which is downloaded from https://hub.docker.com/r/cloudcustodian/c7n |
| run | instructs Cloud Custodian to run a policy. This is the first part of the command line which is passed to CloudCustodian |
| --cache-period 0 | disables cloud custodian's caching of api call results |
| -s /tmp | specifies the directory where log and resource data is placed |
| -c aws-securityhub-automated-remediations-workshop/module1/force-vulnerability-finding.yml | specifies the actual policy to run |

9.  If you received the expected output lines, congratulations, you have successfully tested the environment setup by having Cloud Custodian submit a finding to Security Hub.  Proceed to the next module.


After you have successfully setup your environment, you can proceed to the next module.
