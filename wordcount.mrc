on $*:text:/(nope)\b/iS:#xkcd:{
  inc $+(%,count,$chan)
  echo -a $regml(1) was used in $chan $($+(%,count,$chan),2) time(s) since 5/18/2012
}
