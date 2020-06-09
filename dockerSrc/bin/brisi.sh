#!/bin/bash
su - postgres -c "psql rnms -c \"delete from kartice;\""; su - postgres -c " psql rnms -c \"delete from sucelja;\""; su - postgres -c "psql rnms -c \"delete from uredjaji;\""
rm -f /var/opt/RNMS/http/grafovi/*
rm -f /var/opt/RNMS/rrdb/* 2>/dev/null
crontab -r
