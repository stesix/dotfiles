totp() {
    local MYPIN MYKEY

    if [ -z "$1" ] ; then
        echo 'Missing key'
        return 1
    fi
    
    MYKEY=$( grep "$1=" ~/.secrets/totp | awk -F= '{ print $2 }' )
    MYPIN=$( oathtool --totp -b $MYKEY )
    echo -n "$MYPIN" | pbcopy
    echo "Copied!"
}
