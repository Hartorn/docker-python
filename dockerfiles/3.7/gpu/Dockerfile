# DO NOT MODIFY MANUALLY
# GENERATED FROM SCRIPTS
FROM nvidia/cuda:11.0-devel-ubuntu20.04@sha256:0fe0406ec4e456ae682226751434bdd7e9b729a03067d795f9b34c978772b515

# Avoid tzdata interactive action
ENV DEBIAN_FRONTEND noninteractive

# Adding Python to image

# Dockerfile generated fragment to install Python and Pip
# Source: https://raw.githubusercontent.com/docker-library/python/master/3.7/buster/slim/Dockerfile
# Python: 3.7.9
# Pip: 20.2.2




# ensure local python is preferred over distribution python
ENV PATH /usr/local/bin:$PATH

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
		ca-certificates \
		netbase \
	&& rm -rf /var/lib/apt/lists/*

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.7.9

RUN set -ex \
	\
	&& savedAptMark="$(apt-mark showmanual)" \
	&& apt-get update && apt-get install -y --no-install-recommends \
		dpkg-dev \
		gcc \
		libbluetooth-dev \
		libbz2-dev \
		libc6-dev \
		libexpat1-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncursesw5-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		make \
		tk-dev \
		uuid-dev \
		wget \
		xz-utils \
		zlib1g-dev \
# as of Stretch, "gpg" is no longer included by default
		$(command -v gpg > /dev/null || echo 'gnupg dirmngr') \
	\
	&& wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" \
	&& wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" \
	&& export GNUPGHOME="$(mktemp -d)" \
# Fix to avoid GPG server problem
	&& echo "disable-ipv6" >> ${GNUPGHOME}/dirmngr.conf \
	&& gpg --batch --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& gpg --batch --verify python.tar.xz.asc python.tar.xz \
	&& { command -v gpgconf > /dev/null && gpgconf --kill all || :; } \
	&& rm -rf "$GNUPGHOME" python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz \
	\
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-optimizations \
		--enable-option-checking=fatal \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
		LDFLAGS="-Wl,--strip-all" \
# setting PROFILE_TASK makes "--enable-optimizations" reasonable: https://bugs.python.org/issue36044 / https://github.com/docker-library/python/issues/160#issuecomment-509426916
		PROFILE_TASK='-m test.regrtest --pgo \
			test_array \
			test_base64 \
			test_binascii \
			test_binhex \
			test_binop \
			test_bytes \
			test_c_locale_coercion \
			test_class \
			test_cmath \
			test_codecs \
			test_compile \
			test_complex \
			test_csv \
			test_decimal \
			test_dict \
			test_float \
			test_fstring \
			test_hashlib \
			test_io \
			test_iter \
			test_json \
			test_long \
			test_math \
			test_memoryview \
			test_pickle \
			test_re \
			test_set \
			test_slice \
			test_struct \
			test_threading \
			test_time \
			test_traceback \
			test_unicode \
		' \
	&& make install && cd /usr/local \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' -o -name '*.a' \) \) \
			-o \( -type f -a -name 'wininst-*.exe' \) \
		\) -exec rm -rf '{}' + \
	\
	&& ldconfig \
	\
	&& apt-mark auto '.*' > /dev/null \
	&& apt-mark manual $savedAptMark \
	&& find /usr/local -type f -executable -not \( -name '*tkinter*' \) -exec ldd '{}' ';' \
		| awk '/=>/ { print $(NF-1) }' \
		| sort -u \
		| xargs -r dpkg-query --search \
		| cut -d: -f1 \
		| sort -u \
		| xargs -r apt-mark manual \
	&& apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
	&& rm -rf /var/lib/apt/lists/* \
	\
	&& python3 --version

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python3-config python-config

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 20.2.2
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/5578af97f8b2b466f4cdbebe18a3ba2d48ad1434/get-pip.py
ENV PYTHON_GET_PIP_SHA256 d4d62a0850fe0c2e6325b2cc20d818c580563de5a2038f917e3cb0e25280b4d1

RUN set -ex; \
	\
	savedAptMark="$(apt-mark showmanual)"; \
	apt-get update; \
	apt-get install -y --no-install-recommends wget; \
	\
	wget -O get-pip.py "$PYTHON_GET_PIP_URL"; \
	echo "$PYTHON_GET_PIP_SHA256 *get-pip.py" | sha256sum --check --strict -; \
	\
	apt-mark auto '.*' > /dev/null; \
	[ -z "$savedAptMark" ] || apt-mark manual $savedAptMark; \
	apt-get purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false; \
	rm -rf /var/lib/apt/lists/*; \
	\
	python get-pip.py \
		--disable-pip-version-check \
		--no-cache-dir \
		"pip==$PYTHON_PIP_VERSION" \
	; \
	pip --version; \
	\
	find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \
			\( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
		\) -exec rm -rf '{}' +; \
	rm -f get-pip.py



# Adding NVidia Ml repo
RUN echo "deb https://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1804/x86_64 /" > /etc/apt/sources.list.d/nvidia-ml.list

# Adding CUDNN
ENV CUDNN_VERSION 8.0.2.39
LABEL com.nvidia.cudnn.version=""
RUN apt-get update && apt-get install -y --no-install-recommends  libcudnn8=$CUDNN_VERSION-1+cuda11.0 libcudnn8-dev=$CUDNN_VERSION-1+cuda11.0 && apt-mark hold libcudnn8 && rm -rf /var/lib/apt/lists/*

# Installing TensorRT for cuda 10.1
RUN apt update \
&& apt install libnvinfer7=7.1.3-1+cuda11.0 libnvinfer-dev=7.1.3-1+cuda11.0 libnvinfer-plugin7=7.1.3-1+cuda11.0 libnvinfer-plugin-dev=7.1.3-1+cuda11.0 -y --no-install-recommends \
&& apt autoclean \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*

# Adding useful packages for the image
RUN apt update \
&& apt install gcc-10 g++-10 libgomp1 libopenblas-dev libomp-dev graphviz -y --no-install-recommends \
&& apt autoclean \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*

# Making gcc 10 and g++ 10 default compiler
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 10 \
&& update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 10 \
&& update-alternatives --install /usr/bin/cc cc /usr/bin/gcc 30 \
&& update-alternatives --install /usr/bin/c++ c++ /usr/bin/g++ 30 

# Adding MKL-DNN (now OneDNN) to the image
RUN savedAptMark="$(apt-mark showmanual)" \
&& apt update \
&& apt install make curl wget cmake git -y --no-install-recommends \
&& git clone https://github.com/01org/mkl-dnn.git -b v0.21.5 --depth 1 \
&& cd mkl-dnn/scripts && ./prepare_mkl.sh && cd .. \
&& mkdir -p build && cd build && cmake .. && make \
&& make install \
&& cd ../.. && rm -rf mkl-dnn \
&& apt-mark auto '.*' > /dev/null \
&& apt-mark manual $savedAptMark \
&& apt purge -y --auto-remove -o APT::AutoRemove::RecommendsImportant=false \
&& apt autoclean \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*

ENV LD_LIBRARY_PATH $LD_LIBRARY_PATH:/usr/local/lib

