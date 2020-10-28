#!/bin/bash

mpw() {
    # Empty the clipboard
    :| __copy 2>/dev/null

    # Ask for the user's name and password if not yet known.
    MPW_FULLNAME=${MPW_FULLNAME:-$(ask 'Your Full Name:')}

    # Start Master Password and copy the output.
    printf %s "$(MPW_FULLNAME=$MPW_FULLNAME command mpw "$@")" | __copy
}
