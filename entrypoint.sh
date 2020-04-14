#!/bin/bash
set -u

repo_token=$1

echo "Hello $1"
time=$(date)
echo "::set-output name=time::$time"