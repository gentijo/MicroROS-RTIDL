export NODENAME=mros-rtidl

docker rm $NODENAME

docker run -it \
 --name $NODENAME \
 -h $NODENAME \
 --privileged  \
 -v `pwd`:/opt/rosbots-rtidl  \
 -v /dev:/dev \
 mros-rtidl-img bash 

 

