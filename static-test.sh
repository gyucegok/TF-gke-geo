#!/bin/bash

(tflint && tfsec -f json && terraform validate -json) > static-analysis/all.out
if [ $? == 0 ]; then echo 'ok'; else echo 'not ok'; fi;
