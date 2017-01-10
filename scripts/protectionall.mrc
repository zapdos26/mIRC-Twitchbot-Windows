alias twitchemote {
  var %message = $3-
  var %channel = $2
  var %emotes $1
  var %x = 1
  var %emotecount 0
  while ($gettok(%emotes,%x,47)) {
    tokenize 58 $gettok(%emotes,%x,47)
    tokenize 45 $gettok($2,1,44)
    var %start $calc($1 + 1)
    var %end $calc($2 - $1 + 1)
    var %emote $mid(%message, %start, %end)
    var %lines $numtok(%message,32)
    while (%lines) {
      if ($gettok(%message,%lines,32) === %emote) {
        var %message $deltok(%message,%lines,32)
        if ($hget(emotes. $+ %channel, %emote)) {
          dec %emotecount
        }
        inc %emotecount
      }
      dec %lines
    }
    inc %x
  }
  return %emotecount %message
}
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
  var %channel = $1
  var %nick = $2
  var %sub = $3
  var %regular = $4
  var  %pmessage $6-
  if ($hget(%channel $+ protection,repeat.status) == On ) {
    if ((%regular==1) && ($hget(%channel $+ protection,repeat.regular) == On )) { return }
    if (%sub  == 1) && ($hget(%channel $+ protection,repeat.sub) == On ) { return }
    if (%repeat.text. [ $+ [ %nick ] $+ . $+ [ %channel ] ] != %pmessage || %repeat.times. [ $+ [ %nick ] $+ ] . [ $+ [ %channel ] ] == $null ) {
      set -eu3600 %repeat.times. [ $+ [ %nick ] $+ ] . [ $+ [ %channel ] ] 1
      set -eu3600 %repeat.text. [ $+ [ %nick ] $+ ] . [ $+ [ %channel ] ]  %pmessage
      goto next
    }
    var %repeattext = %repeat.text. [ $+ [ %nick ] $+ ] . [ $+ [ %channel ] ]
    if (%repeattext == %pmessage) {
      inc %repeat.times. [ $+ [ %nick ] $+ . $+ [ %channel ] ]
      var %repeats = %repeat.times. [ $+ [ %nick ] $+ . $+ [ %channel ] ]
      if (%repeats >= $hget(%channel $+ protection,repeat.limitamount)) {
        timeout %channel repeat %nick
        break
      }
    }
  }
  :next
  if ($hget(%channel $+ protection,caps.status) == On ) {
    if ((%regular==1) && ($hget(%channel $+ protection,caps.regular) == On )) { return }
    if (%sub  == 1) && ($hget(%channel $+ protection,caps.sub) == On ) { return }
    if ( $len(%pmessage) >= $hget(%channel $+ protection,caps.limitamount) ) {
      if ( $caps(%pmessage) >= $hget(%channel $+ protection,caps.limitpercentage) ) {
        timeout %channel caps %nick
        halt
      }
    }
  }
  var %plines $numtok(%pmessage,32)
  while (%plines) {
    var %word $gettok(%pmessage,%plines,32)
    if ($hget(blacklist. $+ %channel,%word)) {
      var %pmessage $deltok(%pmessage,%plines,32)
      var %blacklistcount 1
    }
    dec %plines
  } 
  var %emotemessage $twitchemote($5,%channel,%pmessage)
  tokenize 32 %emotemessage
  var %pmessage = $2-
  var %emotecount = $1
  var %wl = 1
  while ($hget(whitelist. $+ %channel,0).item >= %wl) {
    var %pmessage $remove(%pmessage,$hget(whitelist. $+ %channel,%wl).item)
    inc %wl
  }
  if ($hget(%channel $+ protection, links.status) == On ) {
    if ((%regular == 1) && ($hget(%channel $+ protection, links.regular) == On )) { return }
    if (%sub  == 1) && ($hget(%channel $+ protection,links.sub) == On ) { return }
    if ($istok(%permit $+ %channel,%nick,32)) { return }
    var %domain com|edu|gov|mil|net|org|biz|info|name|museum|us|ca|uk|xxx|tv|eu|link|gg|ca|tel|pro|mobi|jobs|asia|arpa|aero|fm|gl|le|ly|png|co|tk|nl|mn|uk|be|ac|me
    if $regex(%pmessage,/([0-9a-zA-z_])([.])( $+ %domain $+ )\b/iS) {
      :linktimeout
      timeout %channel links %nick
      break
    }
  }
  if ($hget(%channel $+ protection, emotes.status) == On) {
    if ((%regular==1) && ($hget(%channel $+ protection,emotes.regular) == On )) { return }
    if (%sub  == 1) && ($hget(%channel $+ protection,emotes.sub) == On ) { return }
    if (%emotecount >= $hget(%channel $+ protection,emotes.limitamount)) {
      timeout %channel emotes %nick
      break
    }
  } 

  if ($hget(%channel $+ protection,symbol.status) == On ) {
    if ((%regular==1) && ($hget(%channel $+ protection,symbol.regular) == On )) { return }
    if (%sub  == 1) && ($hget(%channel $+ protection,symbol.sub) == On ) { return }
    if ( $len(%pmessage) >= $hget(%channel $+ protection,symbol.limitamount) ) {
      if ( $symbols(%pmessage) >= $hget(%channel $+ protection,symbol.limitpercentage) ) {
        timeout %channel symbol %nick
        halt
      }
    }
  }
  if ($hget(%channel $+ protection,spam.status) == On ) {
    if ((%regular == 1) && ($hget(%channel $+ protection,spam.regular) == On )) { return }
    if ((%sub == 1) && ($hget(%channel $+ protection,spam.sub) == On )) { return }
    var %spam = 1
    while ($gettok(%pmessage, %spam, 32) != $null) {
      var %word = $v1
      var %protectionspam. $hget(%channel $+ protection,spam.limitamount)
      set %protectionspam %protectionspam.
      if ($sticky(%word) != $null) {
        timeout %channel spam %nick
        break
      }
      inc %spam
    }
  }
  if ($hget(%channel $+ protection,blacklist.status) == On ) {
    if ((%regular==1) && ($hget(%channel $+ protection,blacklist.regular) == On )) { return }
    if ((%sub  == 1) && ($hget(%channel $+ protection,blacklist.sub) == On )) { return }
    if (%blacklistcount == 1) {
      timeout %channel blacklist %nick     
      break
    }
  }
}
on *:text:!permit*:#: {
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    set -u30 %permit. $+ #  $addtok(%permit,%nick,32)
    msg $chan You have 30 seconds to post a link, $2
  }
}
on *:Text:*:#:{
  if ($msgtags(mod).key == 1) { return }
  if ($nick == $right(#,-1)) { return }
  if (Regular. [ $+ [ # ] ] isin $level($nick)) { var %regular = 1 }
  else { var %regular = 0 }
  var %message $1-
  $protection(#, $nick, $msgtags(subscriber).key, %regular,$msgtags(emotes).key,%message)
}
on *:action:*:#:{
  if ($msgtags(mod).key == 1) { return }
  if ($nick == $right(#,-1)) { return }
  if (Regular. [ $+ [ # ] ] isin $level($nick)) { var %regular = 1 }
  else { var %regular = 0 }
  var %message $1-
  $protection(#, $nick, $msgtags(subscriber).key, %regular,$msgtags(emotes).key,%message)
  if ($hget(# $+ protection, fakedonation.status == On) {
    if (Regular. [ $+ [ # ] ] isin $level($nick)) && ($hget(# $+ protection,fakedonation.regular) == On )) { return }
    if ($msgtags(subscriber).key == 1) && ($hget($1 $+ protection, fakedonation.sub) == On ) { return }
    if ( $ isin $1- || donate isin $1-) {
      timeout $chan fakedonation $nick
      break
    }
  }
}
