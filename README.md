# Deploying-AWS-VPC-and-webservers-with-Terraform
> ![Deploying-AWS-VPC-and-webservers-with-Terraform](/project-architecture.png)


## Introduction

Creating a Virtual Private Cloud (VPC) with public and private subnets is a great way to isolate your applications and resources away from the public internet. This guide will provide step-by-step instructions on how to create a VPC with public and private subnets, a NAT gateway, and an Internet gateway in the Amazon Web Services (AWS) environment. We will use “my demo” as an example name for the VPC throughout this guide.

<br>

## Step-by-Step Guide

## 1. CREATE A VPC
----------------------------------------
1. Log into the AWS console and select the “VPC” service from the Services menu.

2. Click “Create VPC”(choose VPC only) and enter the settings for your new VPC. 

For this example, we will be creating 2 VPCs with the following settings:
- VPC Name: “my demo”
- IPv4 CIDR block: 10.0.0.0/16

3. Click “Create” to create your VPC.

Next select the VPC you just created. Click on Actions tab at the top and select edit VPC settings. Enable DNS hostnames. This will ensure that the instances have DNS hostnames.

<br>
<br>


## 2. CREATE SUBNETS
------------------------------------------------------------

 Next, you will need to create the public and private subnets. Click “Create Subnet” and enter the settings for your public subnet.

Under "VPC ID" select the dropdown and choose the VPC you just created from the list choose "my demo"

Scroll down to "Subnet settings"
For this example, we will be creating a public subnet with the following settings:
- Subnet Name: “my demo public subnet-1”
- Availability Zone:  US East (N. Virginia) / us-east-1c
- IPv4 CIDR block: 10.0.1.0/24

Scroll down to "Add new subnet" Repeat the above for another subnet.
For this example, we will be creating a second public subnet with the following settings:
- Subnet Name: “my demo public subnet-2”
- Availability Zone:  US East (N. Virginia) / us-east-1d
- IPv4 CIDR block: 10.0.2.0/24

Now you will need to create your private subnet. Scroll down to Add new subnet.  and enter the settings for your private subnet.
For this example, we will be creating a private subnet with the following settings:
- Subnet Name: “my demo private subnet-1”
- Availability Zone: US East (N. Virginia) / us-east-1c
- IPv4 CIDR block: 10.0.3.0/24


Create a second private subnet.Scroll down to Add new subnet.  and enter the settings for your private subnet. 
For this example, we will be creating a private subnet with the following settings:
- Subnet Name: “my demo private subnet-2”
- Availability Zone: US East (N. Virginia) / us-east-1d
- IPv4 CIDR block: 10.0.4.0/24

 Click “Create” to create your subnets.

<br>



## 3. NEXT ENABLE AUTO ASSIGN PUBLIC IP FOR THE PUBLIC SUBNETS
------------------------------------------------------------------------------------------

Select the public subnet 1. Click on Actions tab at the top and select "Edit subnet settings". Scroll down  to Enable auto-assign public IPv4 address. Check the box. Save.
Repeat the same step for public subnet 2

<br>




## 4. CREATE  ROUTE TABLE FOR PRIVATE  SUBNETS 
------------------------------------------------------------
Go to Route tablesand click on "create route tables"
name your route table eg "demo-private-RT"
Next, select your VPC for the route table from the dopdown below.
Now click on "create route table"

Once that is created, go to "subnet associations" from the tabs below.
From "Explicit subnet associations" click on "edit subnet associations"
select your private subnets 1&2. 
click on "save associations"

click back on Route table. Your route table has been defined. Here you can name the undefined route table too. e,g "demo-public-RT"

<br>


## 5. CREATE  INTERNET GATEWAY
------------------------------------------------------------
Next go to Internet gateways and Click on  “Create Internet Gateway”. Enter the settings for your Internet gateway.

For this example, we will be creating an Internet gateway with the following settings:
- Name: “my demo Internet gateway”
Click “Create internet gateway” to create your Internet gateway.

Once its been created, it needs to be attached to the VPC.
Click on Actions button at the top. Select attach to VPC. select the VPC to be attached to.
Click on "Attach internet Gateway"

<br>



## 6. ATTACH THE INTERNET GATEWAY TO THE PUBLIC SUBNETS USING ROUTE TABLES
-------------------------------------------------------------------------------
Go to Route tables
Select the public route table i.e  "demo-public-RT"
Go to Routes (below)
click on " Edit routes"
click on " Add routes"
choose 0.0.0.0/0 (for Destination)
(for Target)select  "Internet gateway" from the list and choose the “my demo Internet gateway” 
save changes

<br>



## 7. CREATE  NAT GATEWAY
------------------------------------------------------------
Next, you will need to create a NAT gateway. This will allow the instances in the private subnet to reach the internet for resources.
Go to NAT Gateways. 
Click “Create NAT Gateway” and enter the settings for your NAT gateway.

For this example, we will be creating a NAT gateway with the following settings:
- Name: “my demo NAT gateway”
- Subnet: “my demo public subnet1”
- Allocate Elastic IP: Create new EIP

For "Connectivity type" leave the default settings  "public'

Click “Create NAT gateway” to create your NAT gateway.


<br>



## 8. ATTACH THE NAT GATEWAY TO THE PRIVATE SUBNETS USING ROUTE TABLES
-------------------------------------------------------------------------------
Go to Route tables
Select the Private route table i.e  "demo-private-RT"
Go to Routes (below)
click on " Edit routes"
click on " Add routes"
choose 0.0.0.0/0 (for Destination)
(for Target)select  "NAT gateway" from the list and choose the “my demo nat-gateway” 
CLICK ON "save changes"

<br>


## CREATE SECURITY GROUPS
-----------------------------------------------------------------
Create Security groups for the VPC
Go to security group
Click on Create security group
Name: demo-security-group
Give it a description: My demo VPC-security-group
select the VPC: demo-VPC
Under "Inbound rules" click on "Add rules"
For Type ; All traffic 
For Source:  0.0.0.0/0


Congratulations! You have successfully created a VPC with public and private subnets, a NAT gateway, and an Internet gateway in the Amazon Web Services (AWS) environment. 
Define a route table for the above VPC

<br>
<br>

## CREATE 2 INSTANCES IN THE PRIVATE SUBNET USING AMAZON CLI :
--------------------------------------------------------------

### TO Launch instance in VPC Public 1A
aws ec2 run-instances --image-id ami-0574da719dca65348 --instance-type t2.micro --security-group-ids sg-0a0c3a5d6421e7ce1 --subnet-id subnet-0554ecb422fc8626a --key-name ansiblekeys --user-data file://nginx.txt


### Launch instance in VPC Private 1B
aws ec2 run-instances --image-id ami-0574da719dca65348 --instance-type t2.micro --security-group-ids sg-0a0c3a5d6421e7ce1 --subnet-id subnet-0bc60ce2862d84bc3 --key-name ansiblekeys --user-data file://nginx.txt

Note: --user-data file://nginx.txt (is the userdata file for spinning up nginx)

<br>
<br>

## CREATE 2 INSTANCES IN THE PRIVATE SUBNET:   MANUAL
---------------------------------------------------------
Name intances: Altschool
AMI: Ubuntu Free tier
Instance type: t2.micro
Keypair: ansiblekeys
Network: Altschool VPC
subnet: altschool-private1
security group: Altschool-SG
Advanced details (userdata): userdata-nginx-ubuntu.txt
<br>
<br>


## CREATE AN ELASTIC LOAD BALANCER
---------------------------------------------------------------------
Click on load balancers
Create load balancer
Choose Application Load Balancer
Name: Demo-LB
Scheme: Internet-facing
For Network mapping: choose your VPC "demo-VPC"
For Mappings: Choose the public subnets 1&2 you created in the VPC
Security groups: choose your VPC security group
Listener1:  HTTP:80  

select Target group: Click on "create target group"
Choose a target type: instances
Target group name: demo-target-group
click on "next"
On the "Register Targets" page, select the EC2 instances that you want to register with the target group, and then click on "Add to Registered".
Click on "Include as pending below"
scroll down an click on "create target group"


Go back to load balancer settings under listener, refresh the target group and select the newly created target group "demo-target-group"



## This step is optional. If you have domain name with ssl certificates
-----------------------------------------------------------------------------------
Add another listener:  HTTPS: 443
Select target group:  demo-target-group
scroll down to Secure listener settings
security policy: leave the default settings
For Default SSL/TLS certificate: choose "From ACM"
select certificate: choose the certificate from the drop down menu
---------------------------------------------------------------------------------------

Review the summary
click on create load balancer


Next
Copy the DNS name of the load balancer and check on the browser
If it does't show, wait for few minutes for the settings to configure.
Keep refreshing to see the changes.

<br>
<br>

## POINT THE DOMAIN NAME TO LOAD BALANCER  (CREATE A RECORDS IN ROUTE 53)
-------------------------------------------------------------------------------------------------
Go to ROUTE 53
select hosted zones and choose the Domain in whic you want to host your load Balancer
Click on create record
For record name, type "www" in the box or leave it blank
Record type: choose "A" records
Next, Click on "Alias" to enable it
Route traffic to: From the drop down menu select "Alias to Application and classic Load Balancer"
Choose region: choose the region where the load balancer is created. (us-East-North-Virginia)
Choose the load balancer: e.g dualstack.Demo-LB-1788571605.us-east-1.elb.amazonaws.com
Click on create records

Now copy the domain name and check on your browser.

<br>
<br>

## OTHER STEPS

## HOW TO REQUEST FREE SSL CERTIFICATE FOR DOMAIN NAME ON AWS USING ACM (AMAZON CERTIFICATE MANAGER)

1. Log in to the AWS Management Console and open the Amazon Certificate Manager (ACM)
2. Click on the "Request a Certificate" button.
3. Select the “Request a public certificate” option and click “Next”.
4. Enter the domain name(s) for which you want to request the SSL certificate and scroll down.
5. Select the “DNS validation” option under the Validation method and scroll down.
6. Leave other values on default, scroll down and click on  “Request”.
7. Note that the status is "pending" This will take some minutes.
8. Follow the instructions on the screen to add a CNAME record in Route 53.
9. If the domain is hosted with Route 53, ACM can directly update the Hosted Zone of the domain with a new record set (CNAME record set). This can be done by clicking on Create Record in Route53
10. Click Create, this will create a new record set in the Route 53 Hosted Zone
11. Check for the Hosted Zone in Route 53 to verify if ACM has created a record set for the certificate
12. Now refresh your browser At the ACM to confirm the status has changed to "issued"

<br>
<br>


## ASSOCIATE AN ACM SSL CERTIFICATE WITH AN APPLICATION LOAD BALANCER
-------------------------------------------------------------------------------------------------
1. Open the Amazon EC2 console.
2. In the navigation pane, choose Load Balancers, and then choose your Application Load Balancer.
3. Choose Add listener.
4. For Protocol, choose HTTPS.
5. For port, choose 443.
6. For Default action(s), choose Forward to, and then select your ALB target group from the dropdown list.
7. For Default SSL certificate, choose "From ACM (recommended)" and then choose the ACM certificate.
8. Choose Save.






















