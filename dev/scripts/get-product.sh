#!/bin/bash

id=$1

if [ -z "$id" ]; then
  echo "id is not set. Exiting..."
  exit 1
fi


curl "http://localhost:3000/api/products/${id}"