FROM centos:7

LABEL maintainer "shifanglei7@gmail.com"

ENV FASTDFS_PATH=/opt/fdfs \
    FASTDFS_BASE_PATH=/var/fdfs \
    PORT= \
    GROUP_NAME= \
    NGINX_PATH=/opt/nginx \
    TRACKER_SERVER=


#get all the dependences
RUN yum -y update \
 && yum install -y git gcc make \
 && yum install -y zlib zlib-devel \
 && yum install -y openssl openssl-devel \
 && yum install -y prce prce-devel \
 && yum install -y autoconf automake \
 && yum install -y wget

#create the dirs to store the files downloaded from internet
RUN mkdir -p ${FASTDFS_PATH}/libfastcommon \
 && mkdir -p ${FASTDFS_PATH}/fastdfs \
 && mkdir ${FASTDFS_BASE_PATH} \
 && mkdir -p ${NGINX_PATH}/nginx-download \
 && mkdir -p ${NGINX_PATH}/nginx \
 && mkdir -p ${NGINX_PATH}/fastdfs-nginx-module

#compile the libfastcommon
WORKDIR ${FASTDFS_PATH}/libfastcommon

RUN git clone --branch V1.0.36 --depth 1 https://github.com/happyfish100/libfastcommon.git ${FASTDFS_PATH}/libfastcommon \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/libfastcommon

#compile the fastdfs
WORKDIR ${FASTDFS_PATH}/fastdfs

RUN git clone --branch V5.11 --depth 1 https://github.com/happyfish100/fastdfs.git ${FASTDFS_PATH}/fastdfs \
 && ./make.sh \
 && ./make.sh install \
 && rm -rf ${FASTDFS_PATH}/fastdfs

#download and set nginx
WORKDIR ${NGINX_PATH}/nginx

RUN wget -c https://nginx.org/download/nginx-1.10.1.tar.gz ${NGINX_PATH}/nginx-download \
	&& git clone https://github.com/happyfish100/fastdfs-nginx-module.git ${NGINX_PATH}/fastdfs-nginx-module \
	&& tar zxvf ${NGINX_PATH}/nginx-download/nginx-1.10.1.tar.gz ${NGINX_PATH}/nginx \
	&& ./configure --add-module=${NGINX_PATH}/fastdfs-nginx-module/src \
	&& ./make \
	&& ./make install \
	&& cp ${NGINX_PATH}/fastdfs-nginx-module/src/mod_fastdfs.conf /etc/fdfs/ \
	&& ln -s /var/fdfs/data/ /var/fdfs/data/M00 \
	&& rm -rf ${NGINX_PATH}/nginx-download \
	&& rm -rf ${NGINX_PATH}/nginx \
	&& rm -rd ${NGINX_PATH}/fastdfs-nginx-module

EXPOSE 22122 23000 8080 8888
VOLUME ["$FASTDFS_BASE_PATH", "/etc/fdfs"]   

COPY conf/fastdfs/*.* /etc/fdfs/
COPY conf/nginx/*.* /usr/local/nginx/conf/

COPY start.sh /usr/bin/

#make the start.sh executable 
RUN chmod 777 /usr/bin/start.sh

ENTRYPOINT ["/usr/bin/start.sh"]
CMD ["tracker"]
