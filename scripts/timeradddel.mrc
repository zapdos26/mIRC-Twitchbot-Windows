on *:text:!timer *:#: {
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    if (add == $2) {
      var %timer  $4-
      if ($hget(# $+ timermessages,$3) != $null) { msg # [ $+ $nick $+ ]: Error, This timer $qt($3) is already exist into the database! | break
      }
      else {
        if (-timelength=* iswm $gettok(%timer,1,32)) {
          var %timelength = $remove( $wildtok($4-,-timelength=*,1,32),-timelength=)   
          if ( %timelength !isnum) { msg # Needs a number of seconds :) | halt }
          if (%cooldown < 60) {  msg # Timer is set too low, please inscrease the amount of seconds the timer should run at. | halt }
          var %timer $remtok(%timer, $wildtok($4-,-timelength=*,1,32),1,32)
          hadd # $+ timertimelength $3 %timelength
        }
        else { hadd # $+ timertimelength $3 600 }
        if (-chatlength=* iswm $gettok(%timer,1,32)) {
          var %chatlength = $remove( $wildtok($4-,-chatlength=*,1,32),-chatlength=)   
          if ( %chatlength !isnum) { msg # Needs to be a  number! :) | halt }
          var %timer $remtok(%timer, $wildtok($4-,-chatlength=*,1,32),1,32)
          hadd # $+ timerchatlength $3 %chatlength
        }
        else { hadd # $+ timerchatlength $3 100 }
        hadd  # $+ timermessages $3 %timer
        .timer $+ $3 $+ $chan 0 $hget(# $+ timertimelength,$3) TimerRun # $3
        /hsave -i # $+ timermessages channeldata\ $+ # $+ .ini timermessages
        /hsave -i  # $+ timertimelength channeldata\ $+ # $+ .ini timertimelength
        /hsave -i# $+ timerchatlength channeldata\ $+ # $+ .ini timerchatlength
        msg $chan /me + Timer $3 has been added to the database!
      }
    }
    if (del == $2) {
      if ($hget(# $+ timermessages,$3) == $null) { .msg $chan [ $+ $nick $+ ]: Error, This timer $qt($3) does NOT exist into the database! | return }
      /hdel # $+ timermessages $3      
      /hdel  # $+ timertimelength $3
      /hdel # $+ timerchatlength $3
      /hsave -i # $+ timermessages channeldata\ $+ # $+ .ini timermessages
      /hsave -i # $+ timertimelength channeldata\ $+ # $+ .ini timertimelength
      /hsave -i # $+ timerchatlength channeldata\ $+ # $+ .ini timerchatlength
      .timer $+ $3 $+ . $+ $chan off
      msg $chan /me - Timer $3 has been deleted from the database!
    }
    if (edit == $2) {
      var %timer  $4-
      if  ($hget(# $+ timermessages,$3) == $null) { .msg $chan [ $+ $nick $+ ]: Error, This timer $qt($3) does NOT exist into the database! | return }
      if (-timelength=* iswm $gettok(%timer,1,32)) {
        var %timelength = $remove( $wildtok($4-,-timelength=*,1,32),-timelength=)   
        if ( %timelength !isnum) { msg # Needs a number of seconds :) | halt }
        if (%cooldown < 60) {  msg # Timer is set too low, please inscrease the amount of seconds the timer should run at. | halt }
        var %timer $remtok(%timer, $wildtok($4-,-timelength=*,1,32),1,32)
        hadd # $+ timertimelength $3 %timelength
      }
      else { hadd # $+ timertimelength $3 600 }
      if (-chatlength=* iswm $gettok(%timer,1,32)) {
        var %chatlength = $remove( $wildtok($4-,-chatlength=*,1,32),-chatlength=)   
        if ( %chatlength !isnum) { msg # Needs to be a  number! :) | halt }
        var %timer $remtok(%timer, $wildtok($4-,-chatlength=*,1,32))
        hadd # $+ timerchatlength $3 %chatlength
      }
      else { hadd # $+ timerchatlength $3 100 }
      if ($len(%timer) != 0) {
        hadd  # $+ timermessages $3 %timer
      }
      .timer $+ $3 $+ $chan 0 $hget(# $+ timertimelength,$3) TimerRun # $3 
      /hsave -i  # $+ timermessages channeldata\ $+ # $+ .ini timermessages
      /hsave -i # $+ timertimelength channeldata\ $+ # $+ .ini timertimelength
      /hsave -i  # $+ timerchatlength channeldata\ $+ # $+ .ini timerchatlength
      msg $chan /me -> Timer $3 has been updated!
    }
    if ($2 == on) {
      if ($hget(# $+ timermessages, $3) == $null) { .msg $chan [ $+ $nick $+ ]: Error, This timer $qt($3) does NOT exist into the database! | return }
      elseif ($timer($3 $+ . $+  $chan) != $null) { msg # Timer $3 is already on! }
      else {
        .timer $+ $3 $+ . $+ $chan 0 $hget(# $+ timertimelength,$3) TimerRun # $3
        msg $chan /me -> Timer $3 has been turned on!
      }
    }
    if ($2 == off) {
      if ($hget(# $+ timermessages, $3) == $null) { .msg $chan [ $+ $nick $+ ]: Error, This timer $qt($3) does NOT exist into the database! | return }
      elseif ($timer($3 $+ . $+  $chan) == $null) { msg # Timer $3 is already off! }
      else {
        .timer $+ $3 $+ . $+  $chan off
        msg $chan /me -> Timer $3 has been turned off!
      }
    }
  }
}

on *:text:!timers off:#:{
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    var %numbertimers = $timer(0)
    var %timer = 1
    while (%timer <= %numbertimers) {
      if ($right($timer(%timer),$len(#)) == #) {
        .timer $+ $timer(%timer) off
      }
      inc %timer
    }
    msg # All timers are now off!
  }
}


alias timeropen { 
  .timer $+ $2 $+ . $+ $1 0 $hget($1 $+ timertimelength,$2) TimerRun $1 $2
}

alias TimerRun {
  if (%chat. [ $+ [ $1 ] $+ ] . [ $+  [ $2 ] ]  >= $hget($1 $+ timerchatlength, $2)) {
    if (-command=* iswm $hget($1 $+ timermessages,$2)) {
      set %test $remove($hget($1 $+ timermessages,$2), -command=)
      var %timermessage = $hget($1 $+ commands,$remove($hget($1 $+ timermessages,$2), -command=))
    }
    else {
      var %timermessage $hget($1 $+ timermessages,$2)
    }
    msg $1 %timermessage
    set -e %chat. [ $+ [ $1 ] $+ ] . [ $+ [ $2 ] ] 0
  }
}

alias TimerCheck {
  var %timers = 1
  while (%timers <= $hget($1 $+ timermessages,0).item) {
    if (-command=* iswm $hget($1 $+ timermessages,%timers).data) {
      if ($2  == $remove($hget($1 $+ timermessages,%timers).data, -command=)) {
        set -e %chat $+ . [ $+ [ $1 ] $+ ] . [ $+  [ $2 ] ] 0
        timeropen $1 $hget($1 $+ timermessages,%timers).item
      }
    }
    inc %timers

  }
}
on *:text:*:#:{
  if (($nick != $me) && ($nick != twitchnotify))  {
    var %timers = 1
    while (%timers <= $hget(# $+ timermessages,0).item) { 
      var  %key $hget(# $+ timermessages,%timers).item
      if (%chat. $+ # $+ . $+ %key == $null) { set -e %chat $+ # $+ . $+ %key 1 }
      else { inc %chat. $+ # $+ . $+ %key } 
      inc %timers 
    }
  }
}
