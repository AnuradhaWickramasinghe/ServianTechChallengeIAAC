#!/bin/sh
export db_connection_endpoint=`terraform output db_connection_endpoint`
export alb_dns_name=`terraform output alb_dns_name`
export ecr_repo_name=`terraform output ecr_repo_name`
export ecr_repository_url=`terraform output ecr_repository_url`
export ecr_registry_id=`terraform output ecr_repository_url | cut -d '/' -f1`
 

echo $db_connection_endpoint
echo $alb_dns_name
echo $ecr_repo_name
echo $ecr_repository_url
echo $ecr_registry_id

