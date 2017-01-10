on *:text:!protection*:#:{
  if (($right(#,-1) == $nick) && ( $2 == default ) && ( $3 == set )) {
    if ($hget(# $+ protection) != $null) {
      /hfree # $+ protection
    }
    /hmake # $+ protection
    .timer 1 5 hsave -i # $+ protection channeldata\ $+ # $+ .ini protectionsettings
    /hadd  # $+ protection caps.status on
    /hadd  # $+ protection  emotes.status on
    /hadd  # $+ protection  spam.status on
    /hadd  # $+ protection links.status on
    /hadd  # $+ protection repeat.status on
    /hadd  # $+ protection blacklist.status on
    /hadd  # $+ protection symbol.status on
    /hadd  # $+ protection fakedonation.status on
    /hadd  # $+ protection silent off
    /hadd  # $+ protection caps.message Easy on the caps please.
    /hadd  # $+ protection emotes.message Easy on the emotes please.  
    /hadd  # $+ protection symbol.message Easy on the symbols please. 
    /hadd  # $+ protection links.message Leave the links to the moderators please.
    /hadd  # $+ protection repeat.message Please stop repeating.
    /hadd  # $+ protection spam.message Please don't spam.
    /hadd  # $+ protection blacklist.message Keep it PG please.
    /hadd  # $+ protection fakedonation.message Please don't lie to get attention.
    /hadd  # $+ protection caps.limitamount 8 
    /hadd  # $+ protection emotes.limitamount 8
    /hadd  # $+ protection symbol.limitamount 10
    /hadd  # $+ protection repeat.limitamount 5
    /hadd  # $+ protection spam.limitamount 16
    /hadd  # $+ protection caps.limitpercentage 80
    /hadd  # $+ protection symbol.limitpercentage 90 
    /hadd  # $+ protection spam.limitpercentage 90
    /hadd  # $+ protection caps.timeout 1
    /hadd  # $+ protection emotes.timeout 1
    /hadd  # $+ protection spam.timeout 1
    /hadd  # $+ protection links.timeout 1
    /hadd  # $+ protection repeat.timeout 1
    /hadd  # $+ protection blacklist.timeout 1
    /hadd  # $+ protection symbol.timeout 1
    /hadd  # $+ protection fakedonation.timeout 1
    /hadd  # $+ protection caps.regular off
    /hadd  # $+ protection emotes.regular off
    /hadd  # $+ protection spam.regular off 
    /hadd  # $+ protection links.regular off
    /hadd  # $+ protection repeat.regular off
    /hadd  # $+ protection blacklist.regular off
    /hadd  # $+ protection symbol.regular off 
    /hadd  # $+ protection fakedonation.regular off 
    /hadd  # $+ protection caps.sub off
    /hadd  # $+ protection emotes.sub off
    /hadd  # $+ protection spam.sub off 
    /hadd  # $+ protection links.sub off
    /hadd  # $+ protection repeat.sub off
    /hadd  # $+ protection blacklist.sub off
    /hadd  # $+ protection symbol.sub off 
    /hadd  # $+ protection fakedonation.sub off 
    /hsave -i  # $+ protection channeldata\ $+ # $+ .ini protectionsettings
    msg # The bot's default settings has been set for this channel.
    /hmake emotes. $+ # 
    /hmake blacklist. $+ #
    /hsave -i emotes. $+ # channeldata\ $+ # $+ .ini emotes
    /hsave -i blacklist. $+ # channeldata\ $+ # $+ .ini blacklist
    break
  }
  if ($msgtags(mod).key == 1 || $right(#,-1) == $nick) {
    if ($2 != caps && $2 != emotes && $2 != symbol && $2 != spam && $2 != repeat && $2 != blacklist && $2 != links && $2 != silent && $2 != fakedonation ) { goto failure }
    elseif ($3 != on && $3 != off && $3 != message && $3 != limitamount && $3 != limitpercentage && $3 != add && $3 != del && $3 != whitelist && $3 != timeout && $3 != regular && $3 != sub) { goto failure }
    elseif (($2 == blacklist || $2 == links || $2 == fakedonation) && ( $3 == limitamount || $3 == limitpercentage)) { goto failure }
    elseif (($2 != links) && ($3 == whitelist )) { goto failure }
    elseif (($2 != emotes && $2 != blacklist && $2 != links) && ($3 == add || $3 == del)) { goto failure }
    elseif (($3 == timeout) && ($4 !isnum || $4 == 0)) { goto failure }
    elseif (($2 == repeat || $2 == emotes || $2 == spam ) && ($3 == limitpercentage)) { goto failure } 
    elseif (($3 == regular) && ($4 != On && $4 != off)) { goto failure }
    elseif (($3 == regular) && ($4 == On || $4 == off) && ($hget(# $+ protection, $2 $+ .regular) == $4)) { 
      msg # Regulars are already protected in reference to $2 $+ .
      break
    }
    elseif (($3 == sub) && ($4 != On && $4 != off)) { goto failure }
    elseif (($3 == sub ) && ($4 == On || $4 == off) && ( $hget(# $+ protection, $2 $+ .sub)== $4)) { 
      msg # Subscribers are already protected in reference to $2 $+ .
      break
    }
    elseif (( $2 != silent) && ($3 == On || $3 == Off ) && ($hget(# $+ protection, $2 $+ .status) == $3)) {
      msg # /me $nick $+ , $2 protection is already $3 $+ .
      break
    }
    elseif (($2 == Silent) && ($3 != on && $3 != off )) { goto failure }
    elseif (($2 == Silent) && ($3 == On || $3 == Off )  && ( $hget(# $+ protection, silent) == $3 )) {
      msg # /me $nick $+ , Silent mode is already $3 $+ .
      break
    }
    elseif (($2 == Silent) && ($3 == On || $3 == Off )) {
      /hadd  # $+ protection silent $3 
      msg # /me $nick $+ , Silent mode is now $3 $+ .
      break
    }
    else {
      if ( $3 == On || $3 == Off ) {
        /hadd  # $+ protection  $2 $+ .status $3
        hsave -i # $+ protection channeldata\ $+ # $+ .ini protectionsettings
        msg # $nick $+ , $2 protection has been turned $3 $+ .
        break
      }
      elseif ($3 == add || $3 == del) {
        var %file $2 $+ .ini
        if ($3 == add) {
          if ($hfind($2 $+ . $+ #,$4) == $null) {
            /hadd $2 $+ . $+ #  $4 1
            /hsave -i $2 $+ . $+ # channeldata\ $+ # $+  .ini $2
            if (emotes == $2) { msg # /me $4 will no longer be counted against the maximum emote limit. }
            else { msg # /me $4 has been added to $2 $+ . }
          }
          else {
            msg # /me $4 is already in $2 $+ . 
          }
        }
        elseif ($3 == del) {
          if ($hfind($2 $+ . $+ #,$4) != $null) {
            /hdel $2 $+ . $+ #  $4
            /hsave -i  $2 $+ . $+ # channeldata\ $+ # $+  .ini $2
            if (emotes == $2) { msg # /me $4 will be counted against the maximum emote limit. }
            else { msg # /me $4 has been removed from $2 $+ . }
          }
          else {
            msg # Sorry, $4 was not found in $2 $+ .
          }
        }
      }
      elseif ($3 == whitelist) && ($4 == add || $4 == del) {
        var %file $3 $+ .ini
        if ($4 == add) {
          /hadd $3 $+ . $+ #  $5 1
          /hsave -i $3 $+ . $+ # channeldata\ $+ # $+ .ini $3
          msg # /me $5 has been added to $3 $+ .
        }
        else {
          msg # /me $5 is already in $3 $+ .
        }
      }
      elseif ($4 == del) {
        if ($hfind($2 $+ . $+ #,$4) != $null) {
          /hdel $3 $+ . $+ #  $5
          /hsave -i $3 $+ . $+ # channeldata\ $+ # $+ .ini $3
          msg # /me $5 has been removed from $3 $+ .
        }
      }

      else {
        /hadd  # $+ protection   [ $2 ] $+ . [ $+ [ $3 ] ] $4-
        hsave -i # $+ protection channeldata\ $+ # $+ .ini protectionsettings
        msg # $nick $+ , $3 has been set for $2 $+ . 
        halt
        :failure
        msg # $nick For more info about how to set the protection settings, visit https://goo.gl/o1Otwc.
        break
      }
    }
  }
}
