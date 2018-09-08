#!/bin/sh

TMP=$(mktemp -d)

trap "rm -r $TMP" EXIT

cd $TMP

touch foo.txt

$POPLOG pop11 <<EOF
sysopen('non-exists-file', 0, "line") =>
;;; out| ** <false>

sysopen('foo.txt', 0, "line") =>
EOF
