#
# Regular cron jobs for the almanna package
#
0 4	* * *	root	[ -x /usr/bin/almanna_maintenance ] && /usr/bin/almanna_maintenance
