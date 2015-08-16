#!/bin/bash -e
# https://gist.github.com/rsanchez/7139776
vhost( ) {
    if [[ -z $1 ]]; then
        echo 'usage: vhost [hostname]'
        return
    fi

    HOST=$1
    HOSTNAME="$HOST.dev"
    ADDRESS="127.0.0.1"
    SITEPATH="$HOME/Sites/$HOST"
    SETTINGSFILE="$HOME/Library/Application Support/appsolute/MAMP PRO/settings.plist"
    HOSTSFILE="$HOME/Library/Application Support/appsolute/MAMP PRO/writtenHosts.plist"

    if [[ ! -d "$SITEPATH" ]]; then
        mkdir "$SITEPATH"
    fi
    
    /usr/libexec/PlistBuddy -c "Add :virtualHosts: dict" "$SETTINGSFILE"
    SETTINGSINDEX=$(/usr/libexec/PlistBuddy -c "Print :virtualHosts: dict" "$SETTINGSFILE" | grep documentRoot | wc -l | tr -d ' ')
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:Allow integer 0" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:AllowOverride integer 0" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:ExecCGI bool false" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:FollowSymLinks bool true" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:Includes bool true" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:Indexes bool false" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:MultiViews bool false" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:Order integer 0" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:SymLinksifOwnerMatch bool false" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:documentRoot string $SITEPATH" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:dyndns dict" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:dyndns:displayName string -" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:local bool true" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:serverAliases array" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:serverName string $HOSTNAME" "$SETTINGSFILE"
    /usr/libexec/PlistBuddy -c "Add :virtualHosts:$SETTINGSINDEX:ssl bool false" "$SETTINGSFILE"

    /usr/libexec/PlistBuddy -c "Add :writtenHosts: array" "$HOSTSFILE"
    HOSTSINDEX=$(/usr/libexec/PlistBuddy -c "Print :writtenHosts: array" "$HOSTSFILE" | grep Array | wc -l | tr -d ' ' | expr $(cat -) - 2)
    /usr/libexec/PlistBuddy -c "Add :writtenHosts:$HOSTSINDEX:0 string $HOSTNAME" "$HOSTSFILE"
    /usr/libexec/PlistBuddy -c "Add :writtenHosts:$HOSTSINDEX:1 string $ADDRESS" "$HOSTSFILE"
}