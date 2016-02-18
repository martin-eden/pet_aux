#!/bin/bash
# Usage: <server_prefix> [<context_length=2>]
server_prefix=${1}
context_length=${2:-2}
cd ./lua
lua ./display_results.lua ../results.lua $context_length | egrep --after-context=$context_length "\(1\)\s+$server_prefix"
cd ..
