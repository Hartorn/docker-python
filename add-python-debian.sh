#!/bin/bash
. "$(readlink -f "${BASH_SOURCE[0]}" | xargs dirname)/utils.sh"

# DEBIAN_VERSION="buster"
# DEBIAN_VARIANT="slim"
# PYTHON_VERSION="3.7"

function install_python() {
    output_file=$1
    python_version=$2   
    # Creating temp folder and entering it
    temp_folder
    source_url="https://raw.githubusercontent.com/docker-library/python/master/${python_version}/buster/slim/Dockerfile"
    wget --quiet ${source_url}
    # Skip 6 first lines (comment)
    tail -n +6 Dockerfile >Dockerfile_trunc
    # Remove CMD
    sed -ie 's/^CMD .*$//g' Dockerfile_trunc
    # Remove FROM
    sed -ie 's/^FROM .*$//g' Dockerfile_trunc

    # Comment under are to keep this version
    PYTHON_PRECISE_VERSION=$(cat Dockerfile_trunc | grep 'ENV PYTHON_VERSION' | sed -e 's/ENV PYTHON_VERSION \(.*\)$/\1/g')
    PIP_PRECISE_VERSION=$(cat Dockerfile_trunc | grep 'ENV PYTHON_PIP_VERSION' | sed -e 's/ENV PYTHON_PIP_VERSION \(.*\)$/\1/g')

    echo '' >>"${output_file}"
    echo '# Dockerfile generated fragment to install Python and Pip' >>"${output_file}"
    echo "# Source: ${source_url}" >>"${output_file}"
    echo "# Python: ${PYTHON_PRECISE_VERSION}" >>"${output_file}"
    echo "# Pip: ${PIP_PRECISE_VERSION}" >>"${output_file}"
    echo "" >>"${output_file}"

    cat Dockerfile_trunc >>"${output_file}"

    # Now, to avoid GPG problems
    # https://github.com/f-secure-foundry/usbarmory-debian-base_image/issues/9
    sed -i 's/^\(.*&&.*export GNUPGHOME="$(mktemp -d)" \)/\1\\\n# Fix to avoid GPG server problem\n\t\&\& echo "disable-ipv6" >> ${GNUPGHOME}\/dirmngr.conf /' "${output_file}"

    # Exiting temp folder and removing it
    cleanup_folder
}