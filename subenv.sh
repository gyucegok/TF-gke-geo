#!/bin/bash

export CURRENT_DIR=${PWD}
for template in $(find . -name '*.tmplate'); do envsubst < ${template} > ${template%.*}; done
mv ${CURRENT_DIR}/templates/*.tf ${CURRENT_DIR}
