on 1:input:*: {
  if ($chr(62) isin $1-) {
    var %str $gettok($1-, 1, 62) $+ 09
    var %i 2
    while (%i <= $numtok($1-, 62)) {
      var %str %str $+ $chr(62) $+ $gettok($1-, %i, 62)
      inc %i
    }
    msg # %str
    haltdef
  }
}
