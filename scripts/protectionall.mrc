alias sticky {
  var %re = /(.)\1{ [ $+ [ %protectionspam ] $+ ] ,}/
  return $iif($regex($1-,%re), $regml(1), $null)
}
alias caps {
  var %text = $strip($remove($1-,$chr(32)))
  var %caps = $calc($regex(%text,/[A-ZÄÖÜ]/g) / $len(%text) * 100)
  return %caps
}
alias symbols {
  var %text = $strip($remove($1-,$chr(32)))
  var %symbols = $calc($regex(%text,/[^a-z0-9]/gi) * 100 / $len(%text))
  return %symbols
}
alias timeout {
  var %message = $hget($1 $+ protection,$2 $+ .message) 
  var %timeout = $hget($1 $+ protection, $2 $+ .timeout)
  msg $1 .timeout $3 %timeout %message
  if ($hget($1 $+ protection,silent) == Off) {
    if (%flood. [ $+ [ $1 ] $+ . $+ [ $2 ] ]) { return } 
    msg $1  $3 $+ , %message
    set -u15 %flood. [ $+ [ $1 ] $+ . $+ [ $2 ] ] On
  }
  return
}

alias protection {
  var  %pmessage $5-
  var %plines $numtok(%pmessage,32)
  var %emotecount 0
  while (%plines) {
    var %word $gettok(%pmessage,%plines,32)
    if ($hget(emotes. $+ $1,%word)) {
      var %pmessage $deltok(%pmessage,%plines,32)
    }
    elseif ($hget(allemotes,%word)) {
      var %pmessage $deltok(%pmessage,%plines,32)
      inc %emotecount
    }
    if ($hget(blacklist. $+ $1,%word)) {
      var %pmessage $deltok(%pmessage,%plines,32)
      var %blacklistcount 1
    }
    dec %plines
  } 
  var %wl = 1
  while ($hget(whitelist. $+ $1,0).item >= %wl) {
    var %pmessage $remove(%pmessage,$hget(whitelist. $+ $1,%wl).item)
    inc %wl
  }
  if ($hget($1 $+ protection, links.status) == On ) {
    if (($4 == 1) && ($hget($1 $+ protection, links.regular) == On )) { return }
    if ($3 == 1) && ($hget($1 $+ protection,links.sub) == On ) { return }
    if ($istok(%permit $+ $1,$2,32)) { return }
    var %domain com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk|xxx|tv|eu|link|gg|ca|tel|pro|mobi|jobs|asia|arpa|aero|fm|gl|le|ly|png|co|tk|nl|mn|uk|be|ac|me
    if $regex(%pmessage,/([0-9a-zA-z_])([.])( $+ %domain $+ )\b/iS) {
      :linktimeout
      timeout $1 links $2
      break
    }
  }
  if ($hget($1 $+ protection, emotes.status) == On) {
    if (($4==1) && ($hget($1 $+ protection,emotes.regular) == On )) { return }
    if ($3 == 1) && ($hget($1 $+ protection,emotes.sub) == On ) { return }
    if (%emotecount >= $hget($1 $+ protection,emotes.limitamount)) {
      timeout $1 emotes $2
      break
    }
  } 
  if ($hget($1 $+ protection,repeat.status) == On ) {
    if (($4==1) && ($hget($1 $+ protection,repeat.regular) == On )) { return }
    if ($3 == 1) && ($hget($1 $+ protection,repeat.sub) == On ) { return }
    if (%repeat.text. [ $+ [ $2 ] $+ . $+ [ $1 ] ] != $5- || %repeat.times. [ $+ [ $2 ] $+ ] . [ $+ [ $1 ] ] == $null ) {
      set -eu3600 %repeat.times. [ $+ [ $2 ] $+ ] . [ $+ [ $1 ] ] 1
      set -eu3600 %repeat.text. [ $+ [ $2 ] $+ ] . [ $+ [ $1 ] ]  $5-
      goto next
    }
    var %repeattext = %repeat.text. [ $+ [ $2 ] $+ ] . [ $+ [ $1 ] ]
    if (%repeattext == $5-) {
      inc %repeat.times. [ $+ [ $2 ] $+ . $+ [ $1 ] ]
      var %repeats = %repeat.times. [ $+ [ $2 ] $+ . $+ [ $1 ] ]
      if (%repeats >= $hget(#$1 $+ protection,repeat.limitamount)) {
        timeout $1 repeat $2
        break
      }
    }
  }
  :next
  if ($hget($1 $+ protection,caps.status) == On ) {
    if (($4==1) && ($hget($1 $+ protection,caps.regular) == On )) { return }
    if ($3 == 1) && ($hget($1 $+ protection,caps.sub) == On ) { return }
    if ( $len(%pmessage) >= $hget($1 $+ protection,caps.limitamount) ) {
      if ( $caps(%pmessage) >= $hget($1 $+ protection,caps.limitpercentage) ) {
        timeout $1 caps $2
        halt
      }
    }
  }
  if ($hget($1 $+ protection,symbol.status) == On ) {
    if (($4==1) && ($hget($1 $+ protection,symbol.regular) == On )) { return }
    if ($3 == 1) && ($hget($1 $+ protection,symbol.sub) == On ) { return }
    if ( $len(%pmessage) >= $hget($1 $+ protection,symbol.limitamount) ) {
      if ( $symbols(%pmessage) >= $hget($1 $+ protection,symbol.limitpercentage) ) {
        timeout $1 symbol $2
        halt
      }
    }
  }
  if ($hget($1 $+ protection,spam.status) == On ) {
    if (($4==1) && ($hget($1 $+ protection,spam.regular) == On )) { return }
    if ($3==1) && ($hget($1 $+ protection,spam.sub) == On ) { return }
    var %spam = 1
    while ($gettok(%pmessage, %spam, 32) != $null) {
      var %word = $v1
      var %protectionspam. $hget($1 $+ protection,spam.limitamount)
      set %protectionspam %protectionspam.
      if ($sticky(%word) != $null) {
        timeout $1 spam $2
        break
      }
      inc %spam
    }
  }
  if ($hget($1 $+ protection,blacklist.status) == On ) {
    if (($4==1) && ($hget($1 $+ protection,blacklist.regular) == On )) { return }
    if ($3 == 1) && ($hget($1 $+ protection,blacklist.sub) == On ) { return }
    if (%blacklistcount == 1) {
      timeout $1 blacklist $2     
      break
    }
  }
}
on *:text:!permit*:#: {
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    set -u30 %permit. $+ #  $addtok(%permit,$2,32)
    msg $chan You have 30 seconds to post a link, $2
  }
}
on *:Text:*:#:{
  if ($msgtags(mod).key == 1) { return }
  if ($nick == $right(#,-1)) { return }
  if (Regular. [ $+ [ # ] ] isin $level($nick)) { var %regular = 1 }
  else { var %regular = 0 }
  var %message $1-
  $protection(#, $nick, $msgtags(subscriber).key, %regular,%message)
}
on *:action:*:#:{
  if ($msgtags(mod).key == 1) { return }
  if ($nick == $right(#,-1)) { return }
  if (Regular. [ $+ [ # ] ] isin $level($nick)) { var %regular = 1 }
  else { var %regular = 0 }
  var %message $1-
  $protection(#, $nick, $msgtags(subscriber).key, %regular,%message)
  if ($hget(# $+ protection, fakedonation.status == On) {
    if (Regular. [ $+ [ # ] ] isin $level($nick)) && ($hget(# $+ protection,fakedonation.regular) == On )) { return }
    if ($msgtags(subscriber).key == 1) && ($hget($1 $+ protection, fakedonation.sub) == On ) { return }
    if ( $ isin $1- || donate isin $1-) {
      timeout $chan fakedonation $nick
      break
    }
  }
}
