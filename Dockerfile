FROM alpine:3.5
LABEL maintainer "Zac Flamig <zflamig@uchicago.edu>"

RUN apk --no-cache add \
	ca-certificates \
	cmake \
	freetype-dev \
	g++ \
	gcc \
	libpng-dev \
	libstdc++ \
	m4 \
	make \
	musl-dev \
	python3 \
	python3-dev \
	wget \
	zlib-dev \
	&& ln -s /usr/include/locale.h /usr/include/xlocale.h \
	&& pip3 install --upgrade pip \
	&& python3 -m pip --no-cache-dir install \
	numpy
# HDF5 Installation
RUN wget https://www.hdfgroup.org/package/bzip2/?wpdmdl=4300 \
        && mv "index.html?wpdmdl=4300" hdf5-1.10.1.tar.bz2 \
        && tar xf hdf5-1.10.1.tar.bz2 \
        && cd hdf5-1.10.1 \
        && ./configure --prefix=/usr --enable-cxx --with-zlib=/usr/include,/usr/lib/x86_64-linux-gnu \
        && make -j4 \
        && make install \
        && cd .. \
        && rm -rf hdf5-1.10.1 \
        && rm -rf hdf5-1.10.1.tar.bz2 \
	&& export HDF5_DIR=/usr

RUN HDF5_LIBDIR=/usr/lib HDF5_INCDIR=/usr/include python3 -m pip --no-cache-dir install \
	--no-binary=h5py h5py

# NetCDF Installation
RUN wget https://github.com/Unidata/netcdf-c/archive/v4.4.1.1.tar.gz \
        && tar xf v4.4.1.1.tar.gz \
        && cd netcdf-c-4.4.1.1 \
        && ./configure --prefix=/usr \
        && make -j4 \
        && make install \
        && cd .. \
        && rm -rf netcdf-c-4.4.1.1 \
        && rm -rf v4.4.1.1.tar.gz

RUN HDF5_LIBDIR=/usr/lib HDF5_INCDIR=/usr/include python3 -m pip --no-cache-dir install \
	notebook \
	requests \
	netcdf4 \
	matplotlib \
	&& mkdir /notebooks

WORKDIR /notebooks
CMD /bin/sh -c "/usr/bin/jupyter-notebook --allow-root --no-browser --ip=0.0.0.0 --notebook-dir=/notebooks"
