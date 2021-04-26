# DO NOT MODIFY MANUALLY
# GENERATED FROM SCRIPTS
FROM nvidia/cuda:10.2-cudnn7-devel-ubuntu18.04@sha256:c88113572a0a0d2ba36d40809748aea4fb8364905fcb0c3f7404080af4639011

# Avoid tzdata interactive action
ENV DEBIAN_FRONTEND noninteractive

# Adding Python to image

# Dockerfile generated fragment to install Python and Pip
# Source: https://raw.githubusercontent.com/docker-library/python/master/3.8/buster/slim/Dockerfile
# Python: 3.8.5
# Pip: 20.2.3




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

ENV GPG_KEY E3FF2839C048B25C084DEBE9B26995E310250568
ENV PYTHON_VERSION 3.8.5

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
	&& make install && cd /usr/local \
	&& rm -rf /usr/src/python \
	\
	&& find /usr/local -depth \
		\( \
			\( -type d -a \( -name test -o -name tests -o -name idle_test \) \) \
			-o \( -type f -a \( -name '*.pyc' -o -name '*.pyo' \) \) \
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
ENV PYTHON_PIP_VERSION 20.2.3
# https://github.com/pypa/get-pip
ENV PYTHON_GET_PIP_URL https://github.com/pypa/get-pip/raw/fa7dc83944936bf09a0e4cb5d5ec852c0d256599/get-pip.py
ENV PYTHON_GET_PIP_SHA256 6e0bb0a2c2533361d7f297ed547237caf1b7507f197835974c0dd7eba998c53c

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



# Installing TensorRT for cuda 10.1
RUN apt update \
&& apt install libnvinfer6=6.0.1-1+cuda10.2 libnvinfer-dev=6.0.1-1+cuda10.2 libnvinfer-plugin6=6.0.1-1+cuda10.2 libnvinfer-plugin-dev=6.0.1-1+cuda10.2 -y --no-install-recommends \
&& apt autoclean \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*

# Adding useful packages for the image
RUN apt update \
&& apt install gcc-8 g++-8 libgomp1 libopenblas-dev libomp-dev graphviz -y --no-install-recommends \
&& apt autoclean \
&& apt clean \
&& rm -rf /var/lib/apt/lists/*

# Making gcc 8 and g++ 8 default compiler
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 10 \
&& update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 10 \
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

