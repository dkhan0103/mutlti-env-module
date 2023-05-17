
# Name

Multi Env Terraform Module



# Description

This Terraform Module can be used to deploy infrastructure in various environments using the 'environment' variable


Previously we were making modules for each environment separately so to overcome this issue I have developed a module that will work for any environment 

I have written this module in such a way that by giving the value of environment we can deploy specific code relevant to that particular environment.

All the other code that is not required for that environment will be skipped.


# Infrastructure Deployed

# Prod:


VPC

Private Subnets

Private EC2 

Instances

Route Table

Route Associations

Security Groups




# NonProd:

VPC

Private Subnets

Public Subnets

Private EC2 Instances

Public EC2 Instances

Route Table

Route Table Association

Internet Gateway

Security Groups


# Note From Developer

I believe this module is a good starting point and more changes can be made to suit the specific requirements 

Cheers 

Danish