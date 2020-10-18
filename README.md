# Servian Tech Challange
### Prerequisite.

- ###### AWS account
- ###### Linux instance with Amazon linux OS
- ###### This machine should have internet

### Steps to deploy application!

  - login to newly created server instance from command line
  - switch user account to root
```sh
        sudo su
```
  - Download deploy.sh
```sh
        wget https://serv-bucket-1234.s3.amazonaws.com/deploy.sh
```
  - Change permissions of file
```sh
        chmod 755 deploy.sh
```
  - Execute deploy script
```sh
        ./deploy.sh
```

### Provide AWS access details

- Provide your AWS Access Key ID
AWS Access Key ID [None]: XXXXXXXXXXXX

- Provide your AWS Secret Access Key :
AWS Secret Access Key [None]: ************

- Provide your default region 
Default region name [None]:”xxxxx”

- Set Default output format in to json
Default output format [None]: json

### Infrastructure provisioning and app deployment 

Wait till the infrastructure provisioning and application deployment complete.

### Access application
At the end it will populate application access load balancer endpoint as below
```diff
access your application : app-lb-tf-808563006.us-east-1.elb.amazonaws.com
```
copy and place it on your browser

