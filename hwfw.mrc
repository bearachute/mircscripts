alias hwfw {
  sockopen lde kiserai.net 80
  %x = $1-
}
on *:SOCKOPEN:lde*:{
  sockwrite -n $sockname GET /hwfw.pl?input= $+ $urlencode(%x) $+ &submit=Convert HTTP/1.1
  sockwrite -n $sockname Host: kiserai.net
  sockwrite -n $sockname Accept-Charset: text/html; charset=utf-8
  sockwrite -n $sockname Content-Type: application/x-www-form-urlencoded
  sockwrite -n $sockname $crlf
}
on *:sockread:lde*:{
  var %fullw | sockread %fullw
  if ($regex($sockname,%fullw,/<p>(.+?)</p><form method=post action=hwfw.pl>/)) { 
    msg $active $regml($sockname,1)
  }
}
alias urlencode return $regsubex($1-,/\G(.)/g,$iif(($prop &amp;&amp; \1 !isalnum) || !$prop,$chr(37) $+ $base($asc(\1),10,16),\1))
