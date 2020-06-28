#!/bin/bash
. pomagalice

echo "Content-Type: text/plain"
echo
$RNMS_PREFIX/bin/brisi.sh 2>&1

