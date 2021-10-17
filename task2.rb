#!/usr/bin/ruby

require 'socket'
require 'concurrent'
require 'net/http'
require 'net/smtp'
require 'uri'
require 'digest'

API_URL = "https://api.myip.ms"
API_ID = "id82530"
API_KEY = "302167897-127171339-778362026"

SMTP_ADDR = 'smtp.gmail.com'
SMTP_PORT = 587
FROM_ADDR = '<YOUR-EMAIL>'
TO_ADDR = '<TARGET-EMAIL>'
APP_PASSWD = '<APP-PASSWORD>'

TIMEOUT = 2
THREAD_COUNT = 64

COMMON_PORTS = {
  1=>'tcpmux',
  5=>'rje',
  7=>'echo',
  9=>'discard',
  11=>'systat',
  13=>'daytime',
  17=>'qotd',
  18=>'msp',
  19=>'chargen',
  20=>'ftp',
  21=>'ftp',
  22=>'ssh',
  23=>'telnet',
  25=>'smtp',
  37=>'time',
  39=>'rlp',
  42=>'nameserver',
  43=>'nicname',
  49=>'tacacs',
  50=>'re',
  53=>'domain',
  63=>'whois',
  67=>'bootps',
  68=>'bootpc',
  69=>'tftp',
  70=>'gopher',
  71=>'netrjs',
  72=>'netrjs',
  73=>'netrjs',
  79=>'finger',
  80=>'http',
  88=>'kerberos',
  95=>'supdup',
  101=>'hostname',
  105=>'csnet',
  107=>'rtelnet',
  109=>'pop2',
  110=>'pop3',
  111=>'sunrpc',
  113=>'auth',
  115=>'sftp',
  117=>'uucp',
  119=>'nntp',
  123=>'ntp',
  137=>'netbios',
  138=>'netbios',
  139=>'netbios',
  143=>'imap',
  161=>'snmp',
  162=>'snmptrap',
  163=>'cmip',
  164=>'cmip',
  174=>'mailq',
  177=>'xdmcp',
  178=>'nextstep',
  179=>'bgp',
  191=>'prospero',
  194=>'irc',
  199=>'smux',
  201=>'at',
  202=>'at',
  204=>'at',
  206=>'at',
  209=>'qmtp',
  210=>'z39',
  213=>'ipx',
  220=>'imap3',
  245=>'link',
  347=>'fatserv',
  363=>'rsvp_tunnel',
  369=>'rpc2portmap',
  370=>'codaauth2',
  372=>'ulistproc',
  389=>'ldap',
  427=>'svrloc',
  434=>'mobileip',
  435=>'mobilip',
  443=>'https',
  444=>'snpp',
  445=>'microsoft',
  464=>'kpasswd',
  468=>'photuris',
  487=>'saft',
  488=>'gss',
  496=>'pim',
  500=>'isakmp',
  535=>'iiop',
  538=>'gdomap',
  546=>'dhcpv6',
  547=>'dhcpv6',
  554=>'rtsp',
  563=>'nntps',
  565=>'whoami',
  587=>'submission',
  610=>'npmp',
  611=>'npmp',
  612=>'hmmp',
  631=>'ipp',
  636=>'ldaps',
  674=>'acap',
  694=>'ha',
  749=>'kerberos',
  750=>'kerberos',
  765=>'webster',
  767=>'phonebook',
  873=>'rsync',
  992=>'telnets',
  993=>'imaps',
  994=>'ircs',
  995=>'pop3s'
}

def get_ip(host)
  addrinfo = Socket.getaddrinfo(host, nil)
  ip = addrinfo[0][3]
  return ip
end

def scan_port(port, host)
  sock = Socket.new(:INET, :STREAM)
  remote_addr = Socket.sockaddr_in(port, host)

  begin
    sock.connect_nonblock(remote_addr)
  rescue Errno::EINPROGRESS
  end

  _, sockets, _ = IO.select(nil, [sock], nil, TIMEOUT)

  result = -1
  if sockets
    begin
      sock.write("A")
      result = 1
    rescue Errno::EHOSTUNREACH
    end
  end

  sock.close
  return result
end

def get_info(api_url, api_id, api_key, query)
  tarr = Time.now.utc.to_s.split(' ')
  timestamp = tarr[0] + '_' + tarr[1]
  body = "#{api_url}/#{query}/api_id/#{api_id}/api_key/#{api_key}/timestamp/#{timestamp}"
  signature = Digest::MD5.hexdigest body
  url = "#{api_url}/#{query}/api_id/#{api_id}/api_key/#{api_key}/signature/#{signature}/timestamp/#{timestamp}"

  uri = URI(url)
  info = Net::HTTP.get(uri)
  return info
end


# Scan for open ports
host = ARGV[0]
ip = get_ip(host)

PORT_LIST = 1..65536
open_ports = Concurrent::Array.new

pool = Concurrent::FixedThreadPool.new(THREAD_COUNT)
PORT_LIST.each do |port|
  pool.post do
    result = scan_port(port, ip)
    unless result == -1
      open_ports << port
    end
  end
end

pool.shutdown
pool.wait_for_termination


# Get info on hostname
query = host
info = get_info(API_URL, API_ID, API_KEY, query)
info.gsub!(/\\/, "")
msg1 = info


# Get open ports
msg = ""
msg << "Scanned: #{host}\n"
msg << "IP: #{ip}\n"

msg << "\n"
msg << "PORT\tSTATE\tSERVICE\n"
open_ports.each do |port|
  service = COMMON_PORTS[port]
  msg << "#{port}\topen\t#{service}\n"
end


# Get Banner
msg2 = ""
payload = "AAAAAA\r\n"
open_ports.each do |port|
  sock = TCPSocket.new(ip, port)
  sock.write(payload)

  msg2 << "\n"
  msg2 << "="*60 + "\n"
  msg2 << "Port: #{port}\n"
  msg2 << "="*60 + "\n"
  while line=sock.gets
    msg2 << line
  end
  msg2 << "="*60 + "\n"
  msg2 << "\n"
end


# Send mail
encodedinfo = [msg1].pack("m")
encodedbanner = [msg2].pack("m")

marker = "ENDOFMESSAGE"

part1 = <<EOF
From: portscanner.rb <tinytrebuchet>
To: #{TO_ADDR}
Subject: Scan report for #{host}
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary = #{marker}
--#{marker}
EOF

part2 = <<EOF
Content-Type: text/plain
Content-Transfer-Encoding:8bit

#{msg}
--#{marker}
EOF

part3 = <<EOF
Content-Type: multipart/mixed; name = \"info.txt\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename = "info.txt"

#{encodedinfo}
--#{marker}
EOF

part4 = <<EOF
Content-Type: multipart/mixed; name = \"banner_grab.txt\"
Content-Transfer-Encoding:base64
Content-Disposition: attachment; filename = "banner_grab.txt"

#{encodedbanner}
--#{marker}--
EOF

mailtext = part1 + part2 + part3 + part4

smtp = Net::SMTP.new(SMTP_ADDR, SMTP_PORT)
smtp.enable_starttls
smtp.start(SMTP_ADDR, FROM_ADDR, APP_PASSWD, :login) do
  smtp.send_message(mailtext, FROM_ADDR, TO_ADDR)
end
