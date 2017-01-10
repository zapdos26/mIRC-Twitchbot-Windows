alias -l customcooldown {
  return -u $+ $1
}
alias commandaliases {
  var %com = $hget($1 $+ commands,$2)
  while (-alias=* iswm %com) {
    var %command  $remove(%com,-alias=)
    var %com $hget($1 $+ commands, %command)
  }
  return %com
}
on *:text:!addcom *:#: {
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    var %com = $3-
    if ($hget(# $+ commands,$2) != $null) { .msg $chan [ $+ $nick $+ ]: Error, This command $qt($2) is already exist into the database! | halt }
    elseif ($0 == 2) { .msg $chan [ $+ $nick $+ ]: Error, The command you inputted has no message along with it! | halt  }
    if (-ul=* iswm $gettok(%com,1,32)) {
      var %userlevel $wildtok(%com,-ul=*,1,32)
      var %com $remtok(%com,%userlevel,1,32)  
      /hadd # $+ commanduserlevels $2 $remove(%userlevel,-ul=)
    } 
    else {
      /hadd # $+ commanduserlevels $2 everyone
    }
    if ( -cd=* iswm $gettok(%com,1,32)) {
      var %cooldown = $remove($wildtok($3-,-cd=*,1,32),-cd=)       
      if (%cooldown < 5) {
        msg # Please set cooldown to equal or more than 5 seconds! 
        halt
      }
      var %com $remtok(%com,$wildtok($3-,-cd=*,1,32),1,32)
      /hadd # $+ commandcooldowns $2 %cooldown
    }
    else {
      /hadd # $+ commandcooldowns $2 30
    }
    /hadd # $+ commands $2 %com
    /hadd # $+ commandcounts $2 0
    /hsave -i   # $+ commands channeldata/ $+ # $+ .ini commandmessages
    /hsave -i  # $+ commandcooldowns channeldata/ $+ # $+ .ini commandcooldowns
    /hsave -i # $+ commanduserlevels channeldata/ $+ # $+ .ini commanduserlevels
    /hsave -i  # $+ commandcounts channeldata/ $+ # $+ .ini commandcounts
    msg $chan /me + Command $2 has been added to the database!
  }
}
on *:text:!delcom *:#: {
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    if ($hget(# $+ commands,$2) == $null ) { .msg $chan [ $+ $nick $+ ]: Error, This command $qt($2) does NOT exist into the database! | return }
    /hdel # $+ commands $2
    /hdel # $+ commanduserlevels $2
    /hdel # $+ commandcooldowns $2
    /hdel # $+ commandcounts $2
    /hsave -i  # $+ commands channeldata/ $+ # $+ .ini commandmessages
    /hsave -i # $+ commandcooldowns channeldata/ $+ # $+ .ini commandcooldowns
    /hsave -i # $+ commanduserlevels channeldata/ $+ # $+ .ini commanduserlevels
    /hsave -i  # $+ commandcounts channeldata/ $+ # $+ .ini commandcounts
    msg $chan /me - Command $2 has been deleted from the database!
  }
}
on *:text:!editcom *:#: {
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick)  {
    if ($hget(# $+ commands,$2) == $null) { .msg $chan [ $+ $nick $+ ]: Error, This command $qt($2) does NOT exist into the database! | return }
    elseif  ($0 == 2) { .msg $chan [ $+ $nick $+ ]: Error, The command you inputted has no message along with it! | return }
    var %com = $3-
    if (-ul=* iswm $gettok(%com,1,32)) {
      var %userlevel $wildtok(%com,-ul*,1,32)
      var %com $remtok(%com,%userlevel,1,32)  
      /hadd # $+ commanduserlevels $2 $remove(%userlevel,-ul=)
    } 
    if (-cd=* iswm $gettok(%com,1,32)) {      
      if ($remove( $wildtok($3-,-cd*,1,32),-cd=) < 5) {
        msg # Please set cooldown to equal or more than 5 seconds! 
        halt
      }
      var %cooldown $wildtok(%com,-cd=*,1,32)
      var %com  $remtok(%com,%cooldown,1,32)
      /hadd # $+ commandcooldowns $2 $remove(%cooldown,-cd=)
    }
    if ($len(%com) != 0) {
      /hadd # $+ commands $2 %com
    }
    /hsave -i # $+ commands channeldata/ $+ # $+ .ini commandmessages
    /hsave -i  # $+ commandcooldowns channeldata/ $+ # $+ .ini commandcooldowns
    /hsave -i  # $+ commanduserlevels channeldata/ $+ # $+ .ini commanduserlevels
    /hsave -i # $+ commandcounts channeldata/ $+ # $+ .ini commandcounts
    msg $chan /me -> Command $2 has been updated!
  }
}

ON *:TEXT:*:#: {
  if ($hget(# $+ commands,$1) == $null) { return }
  if ($msgtags(mod).key == 1 || ($nick == %owner)) && (%floodcommod. [ $+ [ $1 ] $+ ] . [ $+ [ # ] ] == On ) { return }
  elseif ($msgtags(mod).key != 1 && $nick != %owner) && ( %floodcom. [ $+ [ $1 ] $+ ] . [ $+ [ # ] ] == On) { return }
  .set -u5 %floodcommod. $+ $1 $+ . $+ # On
  .set $customcooldown($hget(# $+ commandcooldowns,$1)) %floodcom. $+ $1 $+ . $+ # On
  var %owner $right(#,-1)
  var %com = $commandaliases(#,$1)
  var %com $replace(%com,@touser@,$iif($2,$2,$nick),@user@,$nick,@channel@,$mid(#,2-))
  if ($hget(# $+ commanduserlevels,$1) == sub) && (($msgtags(mod).key != 1) && ($msgtags(subscriber).key != 1) && ($nick != %owner)) { return }
  if ($hget(# $+ commanduserlevels,$1) == reg) && (($msgtags(mod).key != 1) && (Regular. $+ # !isin $level($nick)) && ($nick != %owner))  { return }
  if ($hget(# $+ commanduserlevels,$1) == mod) && (($msgtags(mod).key != 1) && ($nick != %owner)) { return }
  if ($hget(# $+ commanduserlevels,$1) == own) && ($nick != %owner) { return }
  var %com = $replace(%com,@touser@,$iif($2,$2,$nick),@user@,$nick,@target@,$target)
  /hinc # $+ commandcounts $1 1
  if (@count@ isin %com) { 
    var %com $reptok(%com, @count@, $hget(# $+ commandcounts,$1), 1, 32) 
    /hsave -i # $+ commandcounts channeldata/ $+  # $+ .ini commandcounts
  }
  if (@uptime@ isin %com) { 
    var %uptime $twitchuptime($right(#,-1))
    var %com = $replace(%com,@uptime@,%uptime) 
  }
  if (@followage@ isin %com) {
    var %com = $replace(%com,@followage@,$followage($iif($2,$2,$nick),$right(#,-1)))
  }
  if (@followers@ isin %com || @views@ isin %com || @game@ isin %com || @title@ isin %com || @status@ isin %com) {
    var %com = $TwitchAPI($right(#,-1),%com)
  }
  msg $chan %com
  if ( !commands == $1 ) && ( $msgtags(mod).key == 1 || ($nick == %owner)) { msg # .w $nick A list of commands to setup the bot can be found here: https://goo.gl/o1Otwc }
  TimerCheck # $1
}
