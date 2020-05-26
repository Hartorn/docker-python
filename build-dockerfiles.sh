#!/bin/bash
set -e
. "$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)/add-python-debian.sh"
. "$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)/apt-utils.sh"

# We build associative array, with key name and value base image

# We want same base version with, or without cuda
# For now, it will be ubuntu 18.04
declare -A config_from_type
config_from_type["cpu"]='ubuntu:18.04@sha256:3235326357dfb65f1781dbc4df3b834546d8bf914e82cce58e6e6b676e23ce8f'
config_from_type["gpu"]='nvidia/cuda:10.1-cudnn7-devel-ubuntu18.04@sha256:557de4ba2cb674029ffb602bed8f748d44d59bb7db9daa746ea72a102406d3ec'

TENSORT_RT_6_PACKAGES="libnvinfer6=6.0.1-1+cuda10.1 libnvinfer-dev=6.0.1-1+cuda10.1 libnvinfer-plugin6=6.0.1-1+cuda10.1 libnvinfer-plugin-dev=6.0.1-1+cuda10.1"

# Not sure on this : should gcc and g++ be included ?
# Useful for lot's of python install packages, let's go for yes
INSTALL_PACKAGES="gcc-8 g++-8 libgomp1 libopenblas-dev libomp-dev graphviz"

# This are the temp package to install, when building packages or deps
BUILD_PACKAGES="gcc-8 g++-8 curl wget make cmake git gfortran"

# MKL-DNN (or OneDNN now) version to use
ONE_DNN_VERSION="v0.21.5"

# From https://github.com/docker-library/python/
# Here, we give link to raw content on github, on master

for python_version in "3.7" "3.8"; do
    for type in "cpu" "gpu"; do
        echo "Building Python ${python_version} for ${type}"
        folder="$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)/dockerfiles/${python_version}/${type}"
        mkdir -p ${folder}
        output_file="${folder}/Dockerfile"
        # Build FROM directive
        echo "# DO NOT MODIFY MANUALLY" >"${output_file}"
        echo "# GENERATED FROM SCRIPTS" >>"${output_file}"
        echo "FROM ${config_from_type[$type]}" >>"${output_file}"
        echo '' >>"${output_file}"
        # Add DEBIAN_FRONTEND noninteractive to avoid tzdata prompt
        echo '# Avoid tzdata interactive action' >>"${output_file}"
        echo 'ENV DEBIAN_FRONTEND noninteractive' >>"${output_file}"
        echo '' >>"${output_file}"
        # Adding python to the image, based on remote dockerfile from https://github.com/docker-library/python
        echo "Getting Python build from source from official dockerfile in Github"
        echo "# Adding Python to image" >>"${output_file}"
        install_python ${output_file} ${python_version}
        echo '' >>"${output_file}"
        # Adding TensorRT if it's cuda image
        if [ "$type" == "gpu" ]; then
            echo "Adding TensorRT support"
            # Looks like ML CUDA is already installed
            # Keeping link as reminder
            # http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64/nvidia-machine-learning-repo-ubuntu1804_1.0.0-1_amd64.deb
            echo "# Installing TensorRT for cuda 10.1" >>"${output_file}"
            # TODO try to install TensorRT 7 ?
            apt_install_packages ${output_file} "${TENSORT_RT_6_PACKAGES}"
            echo "" >>"${output_file}"
        fi

        echo "# Adding useful packages for the image" >>"${output_file}"
        apt_install_packages ${output_file} "${INSTALL_PACKAGES}"
        echo "" >>"${output_file}"

        echo "Adding OneDNN to the dockerfile"
        echo "# Adding MKL-DNN (now OneDNN) to the image" >>"${output_file}"
        apt_install_temp_packages ${output_file} "${BUILD_PACKAGES}"
        echo "&& git clone https://github.com/01org/mkl-dnn.git -b ${ONE_DNN_VERSION} --depth 1 \\" >>"${output_file}"
        echo "&& cd mkl-dnn/scripts && ./prepare_mkl.sh && cd .. \\" >>"${output_file}"
        echo "&& mkdir -p build && cd build && cmake .. && make \\" >>"${output_file}"
        echo "&& make install \\" >>"${output_file}"

        # https://github.com/oneapi-src/oneDNN/releases/download/v1.3/dnnl_lnx_1.3.0_cpu_gomp.tgz
        # echo "&& curl -L https://github.com/oneapi-src/oneDNN/releases/download/v1.3/dnnl_lnx_1.3.0_cpu_gomp.tgz -o dnnl.tgz \\" >>"${output_file}"
        # echo "&& tar zxvf dnnl.tgz \\" >>"${output_file}"
        # echo "&& mv dnnl_lnx_1.3.0_cpu_gomp/include/* /usr/local/include \\" >>"${output_file}"
        # echo "&& mv dnnl_lnx_1.3.0_cpu_gomp/lib/* /usr/local/lib \\" >>"${output_file}"
        # echo "&& rm dnnl.tgz && rm -r dnnl_lnx_1.3.0_cpu_gomp \\" >>"${output_file}"

        # echo "&& git clone https://github.com/01org/mkl-dnn.git -b ${ONE_DNN_VERSION} --depth 1 \\" >>"${output_file}"
        # echo "&& cd mkl-dnn && mkdir -p build && cd build \\">>"${output_file}"
        # echo "&& cmake .. \\">>"${output_file}"
        # echo "&& make -j \\">>"${output_file}"
        # echo "&& make install \\">>"${output_file}"
        # echo "&& cd mkl-dnn/scripts && ./prepare_mkl.sh && cd .. \\" >>"${output_file}"
        # echo "&& mkdir -p build && cd build && cmake .. && make \\" >>"${output_file}"
        # echo "&& make install \\" >>"${output_file}"
        apt_clean_temp_packages ${output_file}
        echo "" >>"${output_file}"
        echo 'ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib' >>"${output_file}"
        echo "" >>"${output_file}" >>"${output_file}"
    done
done
