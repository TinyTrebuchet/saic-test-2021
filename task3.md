`$ systemctl start docker`

`$ docker pull ubuntu`

`$ docker run -it -p 8888:8888 -p 9999:9999 ubuntu`
-> starts docker instance

`# apt-get update`	=> fails due to DNS error
-> copy hosts /etc/resolv.conf to docker's /etc/resolv.conf
`# echo "search domain.name
> nameserver 202.56.215.54
> nameserver 59.144.144.100" > /etc/resolv.conf`

`# apt-get update`
`# apt-get install vim git nginx`

`# service nginx status`

`# cd /var/www`
`# git clone https://github.com/KamandPrompt/SAIC-Website.git`
`# git clone https://github.com/KamandPrompt/kamandprompt.github.io.git`

`# cd /etc/nginx`
`# vim sites-enabled/pciitmandi`
`# cat sites-enabled/pciitmandi`
server {
	listen 8888;
	listen [::]:8888;

	server_name pc.iitmandi.co.in;

	root /var/www/kamandprompt.github.io;
	index index.html;

	location / {
		try_files $uri $uri/ =404;
	}
}

`# vim sites-enabled/saic`
`# cat sites-enabled/saic`
server {
	listen 9999;
	listen [::]:9999;

	server_name saic.iitmandi.co.in; 

	root /var/www/SAIC-Website;
	index index.html;

	location / {
		try_files $uri $uri/ =404;
	}
}

`# nginx -t`
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

`# service nginx start`
-> server starts running at localhost:8888 and localhost:9999

`# service nginx stop`
`# exit`

-> back to host os
`$ docker ps -a`
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS                     PORTS     NAMES
8491ed2cb407   ubuntu    "bash"    26 minutes ago   Exited (0) 2 minutes ago             reverent_robinson

`$ docker commit 8491ed2cb407 tinytrebuchet/saic-test-2021:task3`

`$ docker images`
REPOSITORY                     TAG       IMAGE ID       CREATED          SIZE
tinytrebuchet/saic-test-2021   task3     42cfdf72d7e8   14 seconds ago   413MB

`$ docker login`

`$ docker push tinytrebuchet/saic-test-2021:task3`
