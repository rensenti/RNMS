#!/bin/bash
su - postgres -c "psql rnms -c \"delete from kartice;\""; su - postgres -c " psql rnms -c \"delete from sucelja;\""; su - postgres -c "psql rnms -c \"delete from uredjaji;\""
rm -f /RNMS/web_aplikacija/slike/perGrafovi/*
rm -f /RNMS/rrdb/* 2>/dev/null
crontab -r
