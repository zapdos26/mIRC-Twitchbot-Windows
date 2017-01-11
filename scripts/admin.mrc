alias -l MultiTimerRun {
  if (%chat. [ $+ [ $1 ] ] >= 20) {
    msg  $1 %multi. [ $+ [ $1 ] ]
    set %chat. [ $+ [ $1 ] ] 0
  }
}

on *:text:!streamer*:#:{
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    if (raid == $2) {
      if ((@raidtarget@ !isin $3-) && (@link@ isin $3-)) { return }
      else { 
        hadd # $+ settings raid.message $3- 
        msg # Raid Channel Message has been set.
      }
    } 
    elseif (multi == $2) {
      if ((Moderator == $3) && ($4 == On || $4 == Off)) {
        hadd # $+ settings multi.moderator $4
        msg # The Moderator Only !multi has been set to $4 $+ .
      }
      elseif (@multitarget@ !isin $3-) { return }
      else {
        hadd # $+ settings multi.message $3-
        msg # Multi message has been set. 
      }
    }
    elseif (sub == $2) {
      if (@sub@ !isin $3-) { return }
      else {
        hadd # $+ settings sub.message $3-
        msg # Sub message has been set. 
      }
    }
    elseif (resub == $2) {
      if ((@sub@ !isin $3-) || (@month@ !isin $3-))  { return }
      else {
        hadd # $+ settings resub.message $3-
        msg # Resub message has been set. 
      }
    }
    elseif (bits == $2) {
      if (message == $3) {
        hadd # $+ settings bits.message $4- 
        msg # Bits message has been set. 
      }
      elseif ((amount == $3) && ($4 isnum)) {
        hadd # $+ settings bits.amount $4
        msg # Minimum cheer amount has been set. 
      }
    }
    elseif (shoutout == $2) {
      if ($3 == command) {
        hadd # $+ settings shoutout.command $4
        msg # Shoutout command has been set.
      }
      elseif ($3 == message) { 
        hadd # $+ settings shoutout.message $4-
        msg # Shoutout message has been set.
      }
    }
    /hsave -i # $+ settings channeldata/ $+ # $+ .ini settings
    else { msg # $nick $+ , please check out [link] for info on how to use !streamer. }
  }
}


on *:text:!multi*:#: {
  if (!multi != $1) { return }
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    if ($2 == set) {
      set %multi. [ $+ [ # ] ] $hget(# $+ settings, multi.message)
      set %multi. [ $+ [ # ] ] $replace(%multi. [ $+ [ # ] ],@multitarget@,$3)
      /timermulti [ $+ [ # ] ] 0 300 MultiTimerRun #
      msg # Multistreaming with $3 has been turned on.
      halt
    }
    elseif ( $2 == off) {
      /timermulti [ $+ [ # ] ] off
      msg # Multistreaming has been turned off. 
      unset %multi. [ $+ [ # ] ]
      halt
    }
  }
  elseif (($msgtags(mod).key != 1 && $right(#,-1) != $nick) && (%streamer. [ $+ [ # ] $+ ] .multi.mod == On)) { halt }
  msg # %multi. [ $+ [ # ] ]
  set %chat. [ $+ [ # ] ] 0
  /timermulti [ $+ [ # ] ] 0 30 MultiTimerRun #
}




on *:TEXT:!raid *:#: {
  if (($msgtags(mod).key != 1) && ($right(#,-1) != $nick)) { return } 
  if ($$0 < 2) { msg $chan Wrong! Incorrect! Use: !raid [channel name] }
  elseif (twitch == $3) {
    unset %streamer. [ $+ [ # ] $+ ] .raid.streamer. [ $+ [ $2 ] ]
    var %raid. [ $+ [ # ] ] $replace($hget(# $+ settings,raid.message), @link@, https://www.twitch.tv/ , @raidtarget@, $$2)
    .timerraid [ $+ [ # ] ] 4 0 msg # %raid. [ $+ [ # ] ]
  }
  elseif ((%streamer. [ $+ [ # ] $+ ] .raid.streamer. [ $+ [ $2 ] ] == beam) || ( $3 == beam)) {
    set %streamer. [ $+ [ # ] $+ ] .raid.streamer. [ $+ [ $2 ] ] beam
    var %raid. [ $+ [ # ] ] $replace($hget(# $+ settings,raid.message), @link@, https://www.beam.pro/ , @raidtarget@, $$2)
    .timerraid [ $+ [ # ] ] 4 0 msg # %raid. [ $+ [ # ] ]
  }
  else { 
    var %raid. [ $+ [ # ] ] $replace($hget(# $+ settings,raid.message), @link@, https://www.twitch.tv/ ,@raidtarget@, $2)
    .timerraid [ $+ [ # ] ] 4 0 msg # %raid. [ $+ [ # ] ]
  }
}

on *:text:*just subscribed*:#:{
  if ($nick == twitchnotify) && ($4 != to) { 
    var %sub. [ $+ [ # ] ] $replace($hget(# $+ settings,sub.message),@sub@,$$1)
    msg # %sub. [ $+ [ # ] ]
  }
}

raw USERNOTICE:*:{
  if (resub isin $msgtags) {
    var %resub. [ $+ [ $1 ] ] $replace($hget($1 $+ settings,resub.message),@sub@,$msgtags(display-name).key,@month@,$msgtags(msg-param-months).key) 
    msg $1 %resub. [ $+ [ $1 ] ]
  }
}

on *:TEXT:!regular *:#:{
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick)  {
    if (add == $2) {
      if (Regular. $+ # isin $level($3)) {
        msg # /me $3 is already on the Regular List.
      }
      else {
        auser -a Regular. [ $+ [ # ] ] $3
      msg # /me $3 has been added to the Regular List. }
    }
    elseif (del == $2) {
      if (Regular. $+ # isin $level($3)) {
        ruser Regular. $+ # $3
        msg # /me $3 has been removed from the Regular List.
      }
      else {
        msg # /me $3 is not on the Regular List.
      }
    }
  }
}



on *:text:*:#:{
  if ($msgtags(bits).key > 0) && ($msgtags(bits).key >= %streamer. [ $+ [ # ] $+ ] .bits.amount) {
    if ($msgtags(bits).key > 1) { var %bitsamountspecialthing = bits }
    else { var %bitsamountspecialthing = bit }
    var %bitsstreamermessage $replace($hget(# $+ settings,bits.message), @bits@, $msgtags(bits).key, @nick@, $msgtags(display-name).key,@bitsamountspecialthing@,%bitsamountspecialthing )
    msg # %bitsstreamermessage
  }
  if (($hget(# $+ settings,shoutout.command) == $1) && ($msgtags(mod).key == 1 || $right(#,-1) == $nick)) {
    if (twitch == $3) {
      unset %streamer. [ $+ [ # ] $+ ] .shoutout.streamer. [ $+ [ $2 ] ]
      var %shoutout $replace($hget(# $+ settings,shoutout.message), @link@, https://www.twitch.tv/ , @nick@, $2)
      msg # %shoutout
    }
    elseif ((%streamer. [ $+ [ # ] $+ ] .shoutout.streamer. [ $+ [ $2 ] ] == beam) || ($3 == beam)) {
      set %streamer. [ $+ [ # ] $+ ] .shoutout.streamer. [ $+ [ $2 ] ] beam
      var %shoutout $replace($hget(# $+ settings,shoutout.message), @link@, https://www.beam.pro/ , @nick@, $2)
      msg # %shoutout
    }
    else {
      var %shoutout $replace($hget(# $+ settings,shoutout.message), @link@, https://www.twitch.tv/ , @nick@, $2)
      msg # %shoutout
    }
  }
}
