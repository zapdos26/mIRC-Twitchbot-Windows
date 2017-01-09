//Instrctions on how to get you client ID can be found here:https://blog.twitch.tv/client-id-required-for-kraken-api-calls-afbb8e95f843#.pmhe72yy4
alias twitchuptime {
  JSONOpen -uw uptime https://api.twitch.tv/kraken/streams/ $+ $1 $+ ?nocache= $+ $ticks
  JSONUrlHeader uptime Client-ID [Put Client Id Here]
  JSONUrlGet uptime
  var %uptime $iif($JSON(uptime, stream, created_at),$duration($calc($ctime - $TwitchTime($JSON(uptime, stream, created_at))),2),Offline)
  JSONClose uptime
  return %uptime
}

alias followage {
  var %json = json $+ $ticks, %time, %date
  JSONOpen -uw  %json https://api.twitch.tv/kraken/users/ $+ $1 $+ /follows/channels/ $+ $2
  JSONUrlHeader %json Client-ID [Put Client Id Here]
  JSONUrlGet    %json
  var %time = $JSON(%json, created_at)
  JSONClose     %json
  if (%time) {
    %date = $TwitchTime(%time)
    return $duration($calc($ctime - %date), 2) 
  }
  return Not Following
}

alias TwitchAPI {
  var %json = TwitchStreamUpdate
  JSONOpen -du %json https://api.twitch.tv/kraken/channels/ $+ $1 $+ ?client_id=[Put Client Id Here]
  var %com = $2-
  if (@followers@ isin %com) {
    var %com = $replace(%com,@followers@,$JSON(%json, followers))
  }
  if (@game@ isin %com) {
    var %com = $replace(%com,@game@,$JSON(%json,game))
  }
  if (@title@ isin %com) || (@status@ isin %com) {
    var %com = $replace(%com,@title@,$JSON(%json,status),@status@,$JSON(%json,status))
  }
  if (@views@ isin %com) {
    var %com = $replace(%com,@views@,$JSON(%json,views))
  }
  return %com
}

alias TwitchTime {
  if ($regex($1-, /^(\d\d(?:\d\d)?)-(\d\d)-(\d\d)T(\d\d)\:(\d\d)\:(\d\d)(?:(?:Z$)|(?:([+-])(\d\d)\:(\d+)))?$/i)) {
    var %m = $Gettok(January February March April May June July August September October November December, $regml(2), 32), %d = $ord($base($regml(3),10,10)), %o = +0, %t
    if ($regml(0) > 6) %o = $regml(7) $+ $calc($regml(8) * 3600 + $regml(9))
    %t = $calc($ctime(%m %d $regml(1) $regml(4) $+ : $+ $regml(5) $+ : $+ $regml(6)) - %o)
    if ($asctime(zz) !== 0 && $regex($v1, /^([+-])(\d\d)(\d+)$/)) {
      %o = $regml(1) $+ $calc($regml(2) * 3600 + $regml(3))
      %t = $calc(%t + %o )
    }
    return %t
  }
}
