#!/bin/bash

tflint > static-analysis/tflint.out 2>&1
tfsec --no-color > static-analysis/tfsec.out 2>&1
terraform validate -json > static-analysis/tfvalidate.out 2>&1
(tflint && tfsec -f json && terraform validate) > /dev/null 2>&1
if [ $? == 0 ]; then echo 'ok'; else echo 'not ok'; fi;
