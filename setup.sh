
server="nfs_server"
client="nfs_client"

getContainerIp() {
	hostname=${1}
	docker inspect ${hostname} | grep IPAddress | cut -d '"' -f 4 | sed '/^$/d' | sed '$!N; /^\(.*\)\n\1$/!P; D'
}

removeContainerIfRunning() {
	echo "Checking if container ${1} is running"
      	running=`docker ps -a | grep ${1}`
	if [[ "${running}" != "" ]];
	then
		docker rm -f --volumes=true ${1}
		echo "Stopped docker container with name ${1}"
	fi
}

removeContainerIfRunning ${server}
removeContainerIfRunning ${client}
docker build -t ${server} server/
docker build -t ${client} client/
docker run -t -d --name=${client} ${client}
clientIp=$(getContainerIp ${client}) 
docker run --cap-add=ALL -v /lib/modules:/lib/modules --privileged -t -d -e clientIp=${clientIp} --name=${server} ${server}
serverIp=$(getContainerIp ${server})
docker exec ${server} mkdir /var/nfs
docker exec ${server} sh -c 'echo "/home ${clientIp}(rw,fsid=1,sync,no_root_squash,no_subtree_check)" >> /etc/exports'
#docker exec ${server} sh -c 'echo "/var/nfs ${clientIp}(rw,fsid=1,sync,no_subtree_check)" >> /etc/exports'
docker exec ${server} sh -c 'exportfs -a'
docker exec ${server} sh -c 'rpcbind'
docker exec ${server} sh -c 'service nfs-kernel-server start'

