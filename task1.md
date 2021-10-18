# Task 1: Gain access to a remote server.

After starting the machine, our first task is to identify the ip of the virtual machine in local subnet. I did that by simply doing an nmap scan on the local subnet, since we already know the machine will be hosting a server. There probably are better methods to do the same, but I found this one to be easy and fast in this case.
`nmap 192.168.1.1/24`  
Within a few seconds, we see only 192.168.1.1 and 192.168.1.10 have open http ports, and since 192.168.1.1 is our router interface, the machine has to be 192.168.1.10.

Now we perform an indepth nmap scan of the ip, using service detection.  
`nmap 192.168.1.10 -sV -p-`  
After running the following command, we find only open ports to be 21(ftp), 22(ssh) and 80(http). I tried finding the versions of these service on exploit-db but didn't find a direct vulnerablity. Anyways, the first things to do in this case is checking the ftp for anonymouse access, and directory enumeration on port-80 using gobuster.  
`gobuster dir -e -u http://192.168.1.10/ -w /usr/share/wordlists/dirb/common.txt`  
~~~
http://192.168.1.10/.hta                 (Status: 403) [Size: 277]
http://192.168.1.10/.htpasswd            (Status: 403) [Size: 277]
http://192.168.1.10/.htaccess            (Status: 403) [Size: 277]
http://192.168.1.10/files                (Status: 301) [Size: 312] [--> http://192.168.1.10/files/]
http://192.168.1.10/index.html           (Status: 200) [Size: 183]                                 
http://192.168.1.10/server-status        (Status: 403) [Size: 277] 
~~~
