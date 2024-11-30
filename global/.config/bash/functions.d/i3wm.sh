#!/bin/bash

function remindme {
    local WHAT WHEN
    WHAT=$1
    WHEN=$2
    if [ -z "$WHAT" ] ; then
        echo -n 'What? '
        read WHAT
    fi

    if [ -z "$WHEN" ] ; then
        echo -n 'When? '
        read WHEN
    fi

    echo "/usr/bin/notify-send --app-name=Reminder --urgency=critical '$WHAT'" | at $WHEN
}
