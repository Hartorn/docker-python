#!/bin/bash

function temp_folder(){
    temp_folder=$(mktemp -d ./XXXXXXXX)
    cd ${temp_folder}
}

function cleanup_folder(){
    folder="$(pwd)"
    cd ..
    rm -rf ${folder}
}