#!/bin/sh
swupdate -w "--document-root /var/www/swupdate/ --port 9090" -k /etc/public.pem & >/dev/null 2>&1
