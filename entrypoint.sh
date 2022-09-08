#!/bin/bash

gcloud container clusters get-credentials development --region europe-west1-c
tail -f /dev/null
