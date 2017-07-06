#!/bin/bash

echo "Executing on ubu1"
ssh ubu1 "$1"

echo "Executing on ubu2"
ssh ubu2 "$1"

echo "Executing on ubu3"
ssh ubu3 "$1"

