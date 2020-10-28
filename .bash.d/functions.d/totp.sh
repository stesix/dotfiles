totp() {
    local MYPIN MYKEY

    if [ -z "$1" ] ; then
        echo 'Missing key'
        return 1
    fi

    # Empty the clipboard
    :| __copy 2>/dev/null

    MYKEY=$( grep "$1=" ~/.secrets/totp | awk -F= '{ print $2 }' )
    MYPIN=$( oathtool --totp -b $MYKEY )
    echo -n "$MYPIN" | __copy
    echo "Copied!"
}
