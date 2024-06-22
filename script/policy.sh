#!/bin/bash


ack_controllers="ec2 iam s3 rds"

for controller in $ack_controllers; do
  mkdir -p files/$controller
  curl -f -o files/$controller/inline-policy.json https://raw.githubusercontent.com/aws-controllers-k8s/$controller-controller/main/config/iam/recommended-inline-policy 2>/dev/null 
  curl -f -o files/$controller/recommended-policy https://raw.githubusercontent.com/aws-controllers-k8s/$controller-controller/main/config/iam/recommended-policy-arn 2>/dev/null
done

