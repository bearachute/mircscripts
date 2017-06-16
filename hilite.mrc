ON *:text:*:#:highlighter $1-
ON *action:*:#:highlighter $1-
alias -l highlighter {
  if ($regex($1-,/\Q $+ $me $+ \E\b/iS)) {
    if (!$window(@HL. [ $+ [ $network ] ])) {
      window -Cag2 @HL. [ $+ [ $network ] ] 1 1
    }
    window -g2 @HL. [ $+ [ $network ] ]
    aline -p @HL. [ $+ [ $network ] ] $timestamp $+($chr(40),$chan,$chr(41)) $nick » $1-
    aline -p @HL. [ $+ [ $network ] ] -
  }
}
