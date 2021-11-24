#!/bin/bash

for template in $(find . -name '*.tmplate'); do envsubst < ${template} > ${template%.*}; done
