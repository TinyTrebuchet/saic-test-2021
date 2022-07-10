# Task 2: Write a script that takes a target domain/ip as input and performs the given actions

The [script](https://github.com/TinyTrebuchet/saic-test-2021/blob/main/task2.rb) is basic port scanner written in ruby. I chose ruby for the script, as I was learning it for metasploit and wanted to work on a project to get some experience using it.  
The script requires 'concurrent' gem to be installed, which can be done by: `gem install concurrent-ruby`  

The script firstly uses the socket module to get the ip of the given domain name, and then runs a port scanner on all ports, checking which ports are read-to-write AND actually writable (eg. ftp port which came up as ready-to-write but wasn't writable during testing), and marking them as open. It uses multithreading to speed things up, dividing the tasks into smaller units and giving it to a thread pool. Higher thread count means lesser time to scan all ports, but it also comes with the risk of host just dropping the incoming packets because they are arriving too fast. I found 64 threads to be a good figure, but it can be changed by modifiying the THREAD_COUNT constant.  

Then, the script uses the net/http module to get all info about the give ip using the api provided by https://myip.ms, including geo-location and other info about the domain, all of which is later mailed to the target in json format. However, the free account only allows 150 uses, and has to be updated after that (by either using a new API_ID and API_KEY or buying their premium services).

After that, the script has to perform service detection. I thought of two possible solutions: 
1. If it's a well-known port (ie. less than 1024), the service hosted on that port can be easily predicted using a dictionary consisting of all services run on well-known ports, but it might be inaccurate.
2. Perform banner-grabbing on all open ports and then identifying the service by fingerprinting the banner using a pre-known database of all banners of different services.  

I found the 2nd part a little hard to implement, as I couldn't come across such a database with banners of all popular services, and therefore left it out for now. Instead, the script performs the 1st part and then performs banner grabbing on all open ports using a TCPSocket and sending an arbitrary payload, assembles it into a single text file, and mails it to the target later. This way, the script also has an added feature of naive banner grabbing on the open ports, which can be examined in detail by the target at his convenience.  

Finally, the script has to mail the results to the target, from user. I used the net/smtp module to send the mail along with the necessary attachments. If the user is using gmail, he has to put his email in the FROM_ADDR constant, the target's mail (to whom he wants to mail, could be himself) in the TO_ADDR constant, and the app-password in APP_PASSWD constant. If he's not using gmail, then he has to modify the SMTP_ADDR and SMTP_PORT too according to his email provider's smtp server. There is also the issue of leaving plaintext password (though it's supposed to be an app-password and not the actual password) in open, which I left as it is for now. So, the script's read permissions should be appropriately modified.  

The script takes about half an hour or more to scan all the ports, so it should be preferably backgrounded using '&' when run. If you want the script to be executed periodically, say every day, you can use crontabs to do this for you. Use: `crontab -e` and add `0 15 * * * port_scanner.rb` to run it everyday at 3pm. Be sure to use absolute path for the port_scanner.rb  

![s1](https://user-images.githubusercontent.com/73381089/137683458-9cd25b3c-3d2c-40bf-ab81-bdc0bdc004f2.png)  

![2021-10-18-132520_1920x1080_scrot](https://user-images.githubusercontent.com/73381089/137690836-095a4c9a-a978-4100-9659-e0744f692ddd.png)  

![2021-10-18-132534_1920x1080_scrot](https://user-images.githubusercontent.com/73381089/137690876-e425c2b7-cae7-4a68-9ed2-477128d3278e.png)  

### Things Learnt
1. Multi-threading, socket programming, and smtp in ruby, what thread pools are and how they work
2. Worked with online apis for the first time
3. Got more confidence in writing ruby scripts
