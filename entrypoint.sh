#!/bin/bash

gcloud container clusters get-credentials development --region europe-west1-c
/bin/k9s
#tail -f /dev/null