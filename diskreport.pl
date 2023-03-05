#!/usr/bin/perl
# Disk Reporter
# Webpods, LLC - Robert Taylor
# github.com/webpods/scripts/

START:

do_options();


if ($choice eq '0') {
	exit 0;
}

elsif ($choice eq '1') {
    print "\n\n-----\n";
    print "\nFinding (not deleting) large achives that are >100MB in size...\n";
    do_archives();
}

elsif ($choice eq '2') {
    print "\n\n-----\n";
    print "Deleting all php error_log files >100MB in size...\n";
    do_errorlogs();
}

elsif ($choice eq '3') {
    print "\n\n-----\n";
    print "Deleting all trash email from users trash folders...\n";
    #do_trash();
}

elsif ($choice eq '4') {
    print "\n\n-----\n";
    print "Deleting all webalizer cache files...\n";
    do_webalizer();
}

elsif ($choice eq '5') {
    print "\n\n-----\n";
    print "Finding (not deleting) all backup archives from /home ...\n";
    do_backups();
}
elsif ($choice eq '6') {
    print "\n\n-----\n";
    print "Deleting all softaculous backups from /home ...\n";
    do_softaculous();
}
elsif ($choice eq '7') {
    print "\n\n-----\n";
    print "Deleting all cPanel user trash files ...\n";
    do_cp_trash();
}
elsif ($choice eq '8') {
    print "\n\n-----\n";
    print "Calculating usage in /var/log ...\n";
    do_varlog();
}
elsif ($choice eq '9') { 
   print "\n\n------\n";
   print "Clearing Systemd journal ....\n";
   do_clearjournal();
}

do_summary();
goto START;


sub do_options {
    # BEGIN CHOICE SELECTION
    print "\n";
    print "============================================================\n";
    print "DISK CLEAN BY WEBPODS,LLC \n";
    print "============================================================\n\n";
    print "-> Choose carefully?

    [ 1 ] FIND large archives in /home (>100MB)
    [ 2 ] DELETE all error_log files in /home (>100MB)
    [ 3 ] DELETE all trash email from users [DISABLED]
    [ 4 ] DELETE all webalizer caches (>30 days)
    [ 5 ] FIND all backup archives in /home
    [ 6 ] DELETE all softaculous backup archives from /home
    [ 7 ] DELETE all cPanel user trash files
    [ 8 ] SHOW usage in /var/log
    [ 9 ] CLEAR Systemd Journal (only leave past hour)
    [ 0 ] Exit...

    Your choice (0 to 9): ";

    chomp ($choice=<STDIN>);
}

sub do_summary {
    $after_pct = `df -h / | awk '{print \$5}' | sed '1d'`;
    $after_amount = `df -h / | awk '{print \$4}' | sed '1d'`;

    chomp($after_pct, $after_amount);

    print "\n\n============================================================\n";
    print "\t / has $after_pct free ($after_amount) after the clear!\n";
    print "============================================================\n\n";
}

sub do_archives {
    system('find /home -regextype posix-awk -regex "(.*.rar|.*.zip|.*.tar.gz|.*.rar|.*.tar)" -not -path "/home/virtfs/*" -size +100M -exec ls -lh {} \\; | awk \'{print "[" $5 "]" "\\t" $9 }\'');
    print "\nDone.\n";
    print "\n-----\n\n";
}

sub do_errorlogs {
    system('find /home -type f -name error_log -not -path "/home/virtfs/*" -size +100M -delete');
    print "\nDone.\n";
    print "\n-----\n\n";
}

#sub do_trash {
#    system('find /home/*/mail/.Trash/cur -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/.Trash/new -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/*/*/.Trash/cur -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/*/*/.Trash/new -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/.Deleted*/cur -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/.Deleted*/new -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/*/*/.Deleted*/cur -type f -ctime +30 -delete > /dev/null 2>&1');
#    system('find /home/*/mail/*/*/.Deleted*/new -type f -ctime +30 -delete > /dev/null 2>&1');
#    print "\nDone.\n";
#    print "\n-----\n\n";
#}

sub do_clearjournal {
    system('journalctl --vacuum-time=1h');
    print "\nJournal Cleared.\n";
    print "\n-----\n\n";
}

sub do_cp_trash {
    system('find /home/*/.trash/ -type f -print -delete');
    print "\nDone.\n";
    print "\n-----\n\n";
}

sub do_varlog {
     system('du -chs /var/log/*');
    print "\nDone.\n";
    print "\n-----\n\n";
}

sub do_webalizer {
    system('find /home/*/tmp/webalizer -name "dns_cache.db" -ctime +30 -delete');
    system('find /home/*/tmp/webalizerftp -name "dns_cache.db" -ctime +30 -delete');
    print "\nDone.\n";
    print "\n-----\n\n";
}

sub do_backups {
    system('find /home -maxdepth 5 -type f -name "backup-*" -not -path "/home/virtfs/*" -ls');
    print "\nDone.\n";
    print "\n-----\n\n";
}

sub do_softaculous {
    system('find /home/*/softaculous_backups/ -type f -delete > /dev/null 2>&1');
    print "\nDone.\n";
    print "\n-----\n\n";
}


#EOF

