;Auto Translator by Ford_Lawnmower irc.GeekShed.net #Script-Help
menu Channel {
  .$iif($gettok($hget(autotrans,$+($network,$chan)),3,32) == On && $group(#AutoTrans) == On,$style(1)) AutoTrans
  ..$iif($group(#AutoTrans) == On,$style(1)) Auto Trans Master On/Off: $iif($group(#AutoTrans) == On,.disable,.enable) #AutoTrans  
  ..Auto Trans Setup:dialog $iif($dialog(auto_translator),-v,-m) auto_translator auto_translator
  ..Manage Exclusions:dialog $iif($dialog(auto_translator_exclude),-v,-m) auto_translator_exclude auto_translator_exclude
}
#AutoTrans On
On *:Text:*:#: {
  if (!$timer($+(AutoTrans,$network,$nick))) {
    .timer $+ $+(AutoTrans,$network,$nick) 1 1 noop 
    if ($gettok($hget(autotrans,$+($network,$chan)),3,32) == On) && (!$regex($1,/^[!.@.#.+./.:.-.+]/S)) {
      var %text $urlencode($utfdecode($utfencode($exclude($1-))))
      tokenize 32 $hget(autotrans,$+($network,$chan))
      AutoTrans $2 $iif($2 == .Msg,$chan,$iif($2 == Echo,$chan,$me)) $iif($4,$+(09[04,$nick,09]),0) $langpair($1),1,32)) %text 0
    }
  }
}
On *:Action:*:#: {
  if (!$timer($+(AutoTrans,$network,$nick))) {
    .timer $+ $+(AutoTrans,$network,$nick) 1 1 noop
    if ($gettok($hget(autotrans,$+($network,$chan)),3,32) == On) {
      var %text $urlencode($exclude($1-))
      tokenize 32 $hget(autotrans,$+($network,$chan))
      AutoTrans $2 $iif($2 == .Msg,$chan,$iif($2 == Echo,$chan,$me)) $iif($4,$+(09[04,$nick,09]),0) $langpair($1),1,32)) %text 0
    }
  }
}
#AutoTrans End
On *:input:*: {
  if ($left($strip($1),2) == \\) && (!$ctrlenter) {
    haltdef
    var %text $inputencode($2-)
    AutoTrans msg $iif($chan,$chan,$active) $me $remove($1,\\) %text 1
  }  
}
on ^$*:Hotlink:/\[([a-zA-Z]{2})\]-\[([a-zA-Z]{2})\]/:#,?:{
  if ($mouse.key == 16) && ($input(Respond through translator $+($regml(2),-,$regml(1)),yn)) {
    if ($?="Please Input your text to be translated") {
      AutoTrans msg $iif($chan,$chan,$nick) $me $regml(1) $urlencode($!) 1
    }   
  }
  halt
}
alias EchoAutoTrans { AutoTrans echo -a $1- }
alias -l AutoTrans {
  var %sockname $+(AutoTrans,$network,$3,$ticks,$r(1,$ticks))
  sockopen %sockname translate.google.com 80
  sockmark %sockname $1-2 $+(/translate_t?langpair=auto|,$4,&text=,$5) $3 $6
}
On *:sockopen:AutoTrans*: {
  if (!$sockerr) {
    sockwrite -nt $sockname GET $gettok($sock($sockname).mark,3,32) HTTP/1.1
    sockwrite -n $sockname Host: translate.google.com
    sockwrite -n $sockname Referer: $+(http://,$ip)
    sockwrite -n $sockname $crlf
  }
  else { echo -st Socket Error $nopath($script) | sockclose $sockname | return }
}
On *:sockread:AutoTrans*: {
  if ($sockerr) { echo -st Socket Error $nopath($script) | sockclose $sockname | return }
  else {
    var %AutoTrans | sockread &AutoTrans
    %autotrans = $bvar(&autotrans,1-4000).text
    if ($regex(lan,%AutoTrans,/id=headingtext\sclass="">(.*?)\sto\s(.*?)\stranslation<\/h3>/i)) noop
    if ($regex(%AutoTrans,/backgroundColor='#fff'">(.*?)<\/span>/i)) {
      var %country $langpair($+([,$regml(lan,1),]-[,$regml(lan,2),],)), %text $replace($fixhtml($regml(1)),quot;,")
      if ($gettok($sock($sockname).mark,5,32)) { $gettok($sock($sockname).mark,1-2,32) %text | sockclose $sockname | return }
      elseif ($matches(%text,$recode($mid($gettok($gettok($sock($sockname).mark,3,32),-2,38),3-)))) {
        $gettok($sock($sockname).mark,1-2,32) 06Translation07 %country $&
          $iif($gettok($sock($sockname).mark,4,32),$gettok($sock($sockname).mark,4,32)) %text
        sockclose $sockname
        return  
      } 
    }    
  }
}
alias -l inputencode { return $regsubex($strip($1-),/([^a-z0-9])/ig,% $+ $base($asc(\t),10,16,2)) }
alias -l exclude { return $regsubex($strip($1-),/(http:\/\/[\S]{1,}|www\.[\S]{1,})/g,$null) }
alias -l urlencode { return $regsubex($1-,/([^a-z0-9])/ig,$urlpairs($asc(\t))) }
alias -l recode { return $regsubex($1-,/%([A-Fa-f0-9]{2})/g,$chr($base(\t,16,10))) }
alias -l fixhtml { return $replace($remove($regsubex($remove($regsubex($1-,/#([\d][\d][\d]?);/g,$chr(\t)),&amp;,gt;,lt;),/\\u([A-Fa-f0-9]{4})/g,$chr($base(\t,16,10))),&amp;,&),&quot;,") }
alias -l notrans { return $iif($hfind(notrans,$1),1,0) }
alias -l matches {
  var %w $numtok($1,32),%x 1,%y 0,%z $numtok($2,32)
  while (%x <= %z) {
    if ($istok($1,$gettok($2,%x,32),32)) || ($notrans($gettok($2,%x,32))) { inc %y }
    inc %x
  }
  return $iif($calc(%y / %w * 100) >= 80,0,1)
}
alias -l UrlPairs {
  if ($1 < 255) { return $+(%,$base($1,10,16)) }
  if ($1 >= 256) && ($1 < 2048) { return $+(%,$base($calc(192 + $div($1,64)),10,16),%,$base($calc(128 + $mod($1,64)),10,16)) }
  if ($1 >= 2048) && ($1 < 65536) { return $+(%,$base($calc(224 + $div($1,4096)),10,16),%,$base($calc(128 + $mod($div($1,64),64)),10,16),%,$base($calc(128 + $mod($1,64)),10,16)) }
}
alias -l div { return $int($calc($1 / $2)) }
alias -l mod {
  var %int $int($calc($1 / $2))
  return $calc($1 - (%int * $2))
}
dialog Auto_Translator {
  title "Auto Translator Setup"
  size -1 -1 118 126
  option dbu
  text "Target Language:", 1, 4 9 45 8, right
  text "Network:", 2, 4 25 45 8, right
  text "Channel:", 3, 4 42 45 8, right
  text "Output Type:", 4, 4 59 45 8, right
  combo 5, 51 8 62 11, drop
  combo 6, 51 24 62 11, drop
  combo 7, 51 41 62 11, drop
  combo 8, 51 58 62 11, drop
  combo 9, 51 77 62 11, drop
  text "Status:", 10, 4 78 45 8, right
  button "Accept", 11, 78 110 34 12
  button "Cancel", 12, 39 110 34 12, cancel
  check "Show Nickname", 13, 63 97 50 10
}
dialog Auto_Translator_Exclude {
  title "Auto Translator Exclusion Manager"
  size -1 -1 144 144
  option dbu
  text "Exclusion:", 1, 4 7 27 8, right
  text "Exclusions", 2, 1 21 142 8, center
  edit "", 3, 33 6 72 10, autohs
  list 4, 6 33 131 94, vsbar
  button "Add", 5, 107 5 29 12
  button "Delete", 6, 50 130 37 12
  button "Close", 7, 97 130 37 12, cancel
}
On *:dialog:Auto_Translator_Exclude:Sclick:5,6: {
  if ($did == 5) && ($did($dname,3).text) { hadd -m notrans $v1 | did -r $dname 3 }
  if ($did == 6) && ($did($dname,4).seltext) { hdel notrans $v1 }
  did -r $dname 4
  didtok $dname 4 32 $regsubex($str(.,$hget(notrans,0).item),/./g,$hget(notrans,\n).item $+ $chr(32))
}
On *:dialog:Auto_Translator_Exclude:init:*: {
  didtok $dname 4 32 $regsubex($str(.,$hget(notrans,0).item),/./g,$hget(notrans,\n).item $+ $chr(32))
}
on *:dialog:Auto_Translator:Sclick:6,7,11: {
  if ($did == 11) {
    tokenize 32 $did($dname,6).seltext $did($dname,7).seltext $did($dname,5).seltext $did($dname,8).seltext $did($dname,9).seltext
    hadd -m autotrans $+($1,$chr(35),$2) $3- $did($dname,13).state
    dialog -x $dname
  }
  if ($did == 6) {
    did -r $dname 7
    didtok $dname 7 35 $chans($did($dname,6).seltext)
    did -fc $dname 7 1
  }
  if ($hget(autotrans,$+($did($dname,6).seltext,$chr(35),$did($dname,7).seltext))) {
    var %match $v1
    did -c $dname 5 $didwm($dname,5,$gettok(%match,1,32))
    did -c $dname 8 $didwm($dname,8,$gettok(%match,2,32))
    did -c $dname 9 $didwm($dname,9,$gettok(%match,3,32))
    did $iif($gettok(%match,4,32),-c,-u) $dname 13
  }
}
on *:dialog:Auto_Translator:init:*: {
  didtok $dname 5 44 AFRIKAANS,ALBANIAN,AMHARIC,ARABIC,ARMENIAN,AZERBAIJANI,BASQUE,BELARUSIAN,BENGALI,BIHARI,BULGARIAN,BURMESE,CATALAN,CHEROKEE
  didtok $dname 5 44 CHINESE,CHINESE_SIMPLIFIED,CHINESE_TRADITIONAL,CROATIAN,CZECH,DANISH,DHIVEHI,DUTCH,ENGLISH,ESPERANTO,ESTONIAN,FILIPINO
  didtok $dname 5 44 FINNISH,FRENCH,GALICIAN,GEORGIAN,GERMAN,GREEK,GUARANI,GUJARATI,HEBREW,HINDI,HUNGARIAN,ICELANDIC,INDONESIAN,INUKTITUT
  didtok $dname 5 44 IRISH,ITALIAN,JAPANESE,KANNADA,KAZAKH,KHMER,KOREAN,KURDISH,KYRGYZ,LAOTHIAN,LATVIAN,LITHUANIAN,MACEDONIAN,MALAY,MALAYALAM
  didtok $dname 5 44 MALTESE,MARATHI,MONGOLIAN,NEPALI,NORWEGIAN,ORIYA,PASHTO,PERSIAN,POLISH,PORTUGUESE,PUNJABI,ROMANIAN,RUSSIAN,SANSKRIT,SERBIAN
  didtok $dname 5 44 SINDHI,SINHALESE,SLOVAK,SLOVENIAN,SPANISH,SWAHILI,SWEDISH,TAJIK,TAMIL,TAGALOG,TELUGU,THAI,TIBETAN,TURKISH,UKRAINIAN
  didtok $dname 5 44 URDU,UZBEK,UIGHUR,VIETNAMESE,WELSH,YIDDISH
  did -c $dname 5 $didwm($dname,5,ENGLISH)
  var %nets $scon(0)
  while (%nets) { scon %nets did -a $dname 6 $!network | dec %nets }
  did -c $dname 6 $didwm($dname,6,$network)
  didtok $dname 7 35 $chans($network)
  did -c $dname 7 $didwm($dname,7,$mid($active,2-))
  didtok $dname 8 44 Echo,.Msg,.Notice
  did -c $dname 8 1
  didtok $dname 9 44 On,Off
  did -c $dname 9 2
  if ($hget(autotrans,$+($network,$active))) {
    var %match $v1
    did -c $dname 5 $didwm($dname,5,$gettok(%match,1,32))
    did -c $dname 8 $didwm($dname,8,$gettok(%match,2,32))
    did -c $dname 9 $didwm($dname,9,$gettok(%match,3,32))
    did $iif($gettok(%match,4,32),-c,-u) $dname 13
  }
}
alias -l LangPair {
  var %return $replace($1-,AFRIKAANS,af,ALBANIAN,sq,AMHARIC,am,ARABIC,ar,ARMENIAN,hy,AZERBAIJANI,az,BASQUE,eu,BELARUSIAN,be,BENGALI,bn,$&
    BIHARI,bh,BULGARIAN,bg,BURMESE,my,CATALAN,ca,CHEROKEE,chr,CHINESE,zh,CHINESE_SIMPLIFIED,CN,CHINESE_TRADITIONAL,TW,$&
    CROATIAN,hr,CZECH,cs,DANISH,da,DHIVEHI,dv,DUTCH,nl,ENGLISH,en,ESPERANTO,eo,ESTONIAN,et,FILIPINO,tl,FINNISH,fi,FRENCH,fr,$&
    GALICIAN,gl,GEORGIAN,ka,GERMAN,de,GREEK,el,GUARANI,gn,GUJARATI,gu,HEBREW,iw,HINDI,hi,HUNGARIAN,hu,ICELANDIC,is,$&
    INDONESIAN,id,INUKTITUT,iu,IRISH,ga,ITALIAN,it,JAPANESE,ja,KANNADA,kn,KAZAKH,kk,KHMER,km,KOREAN,ko,KURDISH,ku,KYRGYZ,ky)
  return $replace(%return,LAOTHIAN,lo,LATVIAN,lv,LITHUANIAN,lt,MACEDONIAN,mk,MALAY,ms,MALAYALAM,ml,MALTESE,mt,MARATHI,mr,MONGOLIAN,mn,NEPALI,ne,$&
    NORWEGIAN,no,ORIYA,or,PASHTO,ps,PERSIAN,fa,POLISH,pl,PORTUGUESE,pt,PUNJABI,pa,ROMANIAN,ro,RUSSIAN,ru,SANSKRIT,sa,$&
    SERBIAN,sr,SINDHI,sd,SINHALESE,si,SLOVAK,sk,SLOVENIAN,sl,SPANISH,es,SWAHILI,sw,SWEDISH,sv,TAJIK,tg,TAMIL,ta,TAGALOG,tl,$&
    TELUGU,te,THAI,th,TIBETAN,bo,TURKISH,tr,UKRAINIAN,uk,URDU,ur,UZBEK,uz,UIGHUR,ug,VIETNAMESE,vi,WELSH,cy,YIDDISH,yi)
}
alias -l chans { scon $netid($1) return $!regsubex($str(.,$chan(0)),/./g,$chan(\n)) }
alias -l netid {
  var %netcount $scon(0)
  while %netcount {
    if ($scon(%netcount).network == $1) { return %netcount }
    dec %netcount
  }
}
On *:Start:{
  hmake AutoTrans 5
  hmake NoTrans 5
  if ($exists(AutoTrans.hsh)) { hload AutoTrans AutoTrans.hsh  }
  if ($exists(NoTrans.hsh)) { hload NoTrans NoTrans.hsh  }
}
On *:Disconnect:{ 
  if ($hget(AutoTrans)) { hsave AutoTrans AutoTrans.hsh } 
  if ($hget(NoTrans)) { hsave NoTrans NoTrans.hsh }   
}
On *:Exit:{ 
  if ($hget(AutoTrans)) {
    hsave AutoTrans AutoTrans.hsh
    hfree AutoTrans 
  }
  if ($hget(NoTrans)) {
    hsave NoTrans NoTrans.hsh
    hfree NoTrans 
  }  
}
On *:Unload:{ hfree AutoTrans | hfree NoTrans }
