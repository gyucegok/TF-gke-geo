#!/bin/bash

for template in $(find . -name '*.tf-tmplate'); do envsubst < ${template} > ${template%.*.tf}; done
