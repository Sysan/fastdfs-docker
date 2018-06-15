# FastDFS Docker

启动方式:
```
docker run -dti --privileged=true --network=host --name fastdfs-tracker -v /var/fdfs/tracker:/var/fdfs sysan/fastdfs-nginx tracker

docker run -dti --privileged=true --network=host --name fastdfs-storage -e TRACKER_SERVER=192.168.0.100:22122 -e -v /var/fdfs/storage:/var/fdfs sysan/fastdfs-nginx storage
```

文件上传通过 22122 端口，通过 8899 端口可用 HTTP 协议访问文件
