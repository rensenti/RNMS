#!/bin/bash
. pomagalice

su - postgres -c "psql rnms -c \"delete from kartice;\""; su - postgres -c " psql rnms -c \"delete from sucelja;\""; su - postgres -c "psql rnms -c \"delete from uredjaji;\""
rm -f $RNMS_PREFIX/web_aplikacija/slike/perGrafovi/*
rm -rf $RNMS_PREFIX/rrdb/* 2>/dev/null
rm -rf $RNMS_PREFIX/netflow/* 2>/dev/null
rm -rf $RNMS_PREFIX/routing/* 2>/dev/null
crontab -r
