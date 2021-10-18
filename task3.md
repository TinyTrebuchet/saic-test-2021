# Task 3: Run multiple sites on the same docker container by mapping different ports on localhost (127.0.0.1) of the host OS.

`$ systemctl start docker`

`$ docker pull ubuntu`

`$ docker run -it -p 8888:8888 -p 9999:9999 ubuntu`
-> starts docker instance

`# apt-get update`	=> fails due to DNS error

-> copy hosts /etc/resolv.conf to docker's /etc/resolv.conf, example given below, use your host os' /etc/resolv/conf

```
# echo "search domain.name
> nameserver 202.56.215.54
> nameserver 59.144.144.100" > /etc/resolv.conf
```

`# apt-get update`

`# apt-get install vim git nginx`

`# cd /var/www`

`# git clone https://github.com/KamandPrompt/SAIC-Website.git`

`# git clone https://github.com/KamandPrompt/kamandprompt.github.io.git`

`# cd /etc/nginx`

`# vim sites-enabled/pciitmandi`

~~~
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
~~~

`# vim sites-enabled/saic`

~~~
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
~~~

`# nginx -t`

> nginx: the configuration file /etc/nginx/nginx.conf syntax is ok  
> nginx: configuration file /etc/nginx/nginx.conf test is successful  

`# service nginx enable`

`# service nginx start`
-> server starts running at localhost:8888 and localhost:9999

`# service nginx stop`

`# exit`


-> back to host os

`$ docker ps -a`
~~~
CONTAINER ID   IMAGE     COMMAND   CREATED          STATUS                     PORTS     NAMES  
8491ed2cb407   ubuntu    "bash"    26 minutes ago   Exited (0) 2 minutes ago             reverent_robinson  
~~~

`$ docker commit 8491ed2cb407 tinytrebuchet/saic-test-2021:task3`

`$ docker images`

~~~
REPOSITORY                     TAG       IMAGE ID       CREATED          SIZE  
tinytrebuchet/saic-test-2021   task3     42cfdf72d7e8   14 seconds ago   413MB  
~~~

`$ docker login`

`$ docker push tinytrebuchet/saic-test-2021:task3`


To run the docker instance on your machine, do:  
`docker pull tinytrebuchet/saic-test-2021:task3`  
`docker run -it -p <p1>:8888 -p <p2>:9999 tinytrebuchet/saic-test-2021:task3` where p1 and p2 should be replaced by the ports on which you want the websites to run on localhost.  

![2021-10-18-124946_1920x1080_scrot](https://user-images.githubusercontent.com/73381089/137685860-b2648304-e2ab-4735-a30f-ab07f30cb4a0.png)  

![2021-10-18-125000_1920x1080_scrot](https://user-images.githubusercontent.com/73381089/137685903-48b0a3e8-726c-4d28-b44b-6f6710f086be.png)  


### Things Learnt
1. Learnt Docker from scratch, how it works and how to use it
2. Learnt nginx from scratch, how it works and how to use it.
