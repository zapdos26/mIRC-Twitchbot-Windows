alias savevariablesandusers {
  .save -rv vars.ini
  .save -ru users.ini
}
on *:start: {
  /load -rvN vars.ini
  /hmake allemotes 1000
  /hload allemotes allemotes.txt
  .timersave -i 0 30 savevariablesandusers 
  server irc.chat.twitch.tv 6667 [oauth token] -i [Bot Name] -j [#Channel_Name]
}

on *:Connect:{
  /raw CAP REQ :twitch.tv/membership
  /raw CAP REQ :twitch.tv/commands
  /raw CAP REQ :twitch.tv/tags
}

on *:join:#: {
  if ($nick == $me) {
    .load -ruN users.ini
    .load -rsN scripts/adddelcom.mrc
    .load -rsN scripts/admin.mrc
    .load -rsN scripts/protectionall.mrc
    .load -rsN scripts/protectionsetup.mrc
    .load -rsN scripts/quotes_clips.mrc
    .load -rsN scripts/twitchapi.mrc
    .load -rsN scripts/timeradddel.mrc
    .load -rsN scripts/JSONForMirc.v0.2.41.mrc
    if ($file(channeldata/ $+ # $+ scripts.mrc) != $null) {
      .load -rsN channeldata/ $+ # $+ scripts.mrc
    }
    /hmake emotes. $+ #
    /hmake blacklist. $+ #
    /hmake # $+ commands
    /hmake # $+ commanduserlevels
    /hmake # $+ commandcounts
    /hmake # $+ commandcooldowns
    /hmake # $+ protection
    /hmake # $+ settings
    /hload -i  # $+ commands channeldata/ $+ # $+ .ini commandmessages
    /hload -i # $+ commandcooldowns channeldata/ $+ # $+ .ini commandcooldowns
    /hload -i  # $+ commanduserlevels channeldata/ $+ # $+ .ini commanduserlevels
    /hload -i # $+ commandcounts channeldata/ $+ # $+ .ini commandcounts
    /hload -i  # $+ protection channeldata/ $+ # $+ .ini protectionsettings 
    /hload -i emotes. $+ #  channeldata/ $+ # $+ .ini emotes
    /hload -i blacklist. $+ # channeldata/ $+ # $+ .ini blacklist  
    /hload -i # $+ protection channeldata/ $+ # $+ .ini protectionsettings
    /hload -i # $+ settings channeldata/ $+ # $+ .ini settings
    /hmake # $+ timermessages
    /hmake # $+ timertimelength
    /hmake # $+ timerchatlength
    /hload -i # $+ timermessages channeldata/ $+ # $+ .ini timermessages
    /hload -i # $+ timertimelength channeldata/ $+ # $+ .ini timertimelength
    /hload -i # $+ timerchatlength channeldata/ $+ # $+ .ini timerchatlength
    var %timers 1
    while (%timers <= $hget(# $+ timermessages,0).item) {
      .timer 1 $rand(30,300) timeropen # $hget( # $+ timermessages,%timers).item
      inc %timers
    }
  }
}
