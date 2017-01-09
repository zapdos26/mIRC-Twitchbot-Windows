on *:TEXT:!quote*:#: {
  if (($msgtags(mod).key != 1 && $right(#,-1) != $nick) && (%floodquote. $+ #) || ($($+(%,floodquote.,$2),2))) { return }
  set -u15 %floodquote. $+ #  On
  if (!$2) { 
    msg # $read(channeldata\ $+ # $+ quotes.txt,n) 
  }
  elseif ($2 == add) && ($3) && ($msgtags(mod).key == 1 || $right(#,-1) == $nick) { .write channeldata\ $+ # $+ quotes.txt $replace($3-,|,$chr(124)) | msg # [Quote Added] $+($lines(# $+ quotes.txt),:) $3- } 
  elseif ($2 == del) && ($3 isnum) && ($lines(# $+ quotes.txt) >= $3) && ($msgtags(mod).key == 1 || $right(#,-1) == $nick) { msg # [Quote Deleted] $3 $+ : $read(channeldata\ $+ # $+ quotes.txt, $+ $3) | .write -dl $+ $3 channeldata\ $+ # $+ quotes.txt }
  elseif ($2 isnum) && ($lines(# $+ quotes.txt) >= $2) { msg # [Quote $+($2,/,$lines(channeldata\ $+ # $+ quotes.txt),]) $read(channeldata\ $+ # $+ quotes.txt,n,$2) }   
  elseif ($2 == find) && ($len($3) > 2) {
    var %x $lines(channeldata\ $+ # $+ quotes.txt)
    while (%x) {
      if ($3- isin $read(channeldata\ $+ # $+ quotes.txt,%x)) {
        inc %quotes.search
        set %quotes.return $addtok(%quotes.return,%x,32)
      }
      dec %x
    }
    if (!%quotes.search) { msg # [Quote Search] No quotes found with the phrase " $+ $3- $+ " | unset %quotes.* | halt }
    if (%quotes.search = 1) { msg # [Quote Search] One quote found: $+([,%quotes.return,]) $read(channeldata\ $+ # $+ quotes.txt,n,%quotes.return) | unset %quotes.* }
    else {
      msg # [Quote Search] Found %quotes.search quotes that have the phrase $+(",$3-,") in them.
      .timer 1 2 msg # [Quote $+($gettok(%quotes.return,1,32),/,$lines(channeldata\ $+ # $+ quotes.txt),])  $replace($read(channeldata\ $+ # $+ quotes.txt, n, $gettok(%quotes.return,1,32)),|,$!chr(124))   
      .timer 1 4 msg # [Quote Search] Other quote numbers: $right(%quotes.return,-2)
      unset %quotes.*
    }
  }
}

on *:TEXT:!clip*:#: {
  if (($msgtags(mod).key != 1 && $right(#,-1) != $nick) && (%floodclip. $+ #) || ($($+(%,floodclip.,$2),2))) { return }
  set -u15 %floodclip. $+ #  On
  if (!$2) { 
    msg # $read(channeldata\ $+ # $+ clip.txt,n) 
  }
  elseif ($2 == add) && ($3) && ($msgtags(mod).key == 1 || $right(#,-1) == $nick) { .write channeldata\ $+ # $+ clip.txt $replace($3-,|,$chr(124)) | msg # [Clip Added] $+($lines(channeldata\ $+ # $+ clip.txt),:) $3- } 
  elseif ($2 == del) && ($3 isnum) && ($lines(# $+ clip.txt) >= $3) && ($msgtags(mod).key == 1 || $right(#,-1) == $nick) { msg # [Clip Deleted] $3 $+ : $read(channeldata\ $+ # $+ clip.txt, $+ $3) | .write -dl $+ $3 channeldata\ $+ # $+ clip.txt }
  elseif ($2 isnum) && ($lines(channeldata\ $+ # $+ clip.txt) >= $2) { msg # [Clip $+($2,/,$lines(channeldata\ $+ # $+ clip.txt),]) $read(channeldata\ $+ # $+ clip.txt,n,$2) }   
}
