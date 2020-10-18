#!/bin/bash
echo "export VTT_DBHOST=$(terraform output db_connection_endpoint)" >> /etc/profile.d/setVars.sh
echo "export alb_dns_name=$(terraform output alb_dns_name)" >> /etc/profile.d/setVars.sh
echo "export ecr_repo_name=$(terraform output ecr_repo_name)" >> /etc/profile.d/setVars.sh
echo "export ecr_repository_url=$(terraform output ecr_repository_url)" >> /etc/profile.d/setVars.sh
echo "export ecr_registry_id=$(terraform output ecr_repository_url | cut -d '/' -f1)" >> /etc/profile.d/setVars.sh


echo $VTT_DBHOST
echo $alb_dns_name
echo $ecr_repo_name
echo $ecr_repository_url
echo $ecr_registry_id