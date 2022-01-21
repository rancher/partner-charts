#!/bin/sh

/bin/shipad root user create $USERNAME --ignore-if-exists << EOF
$PASSWORD
$PASSWORD
EOF
