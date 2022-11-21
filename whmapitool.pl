#!/usr/bin/perl 
# github.com/webpods/scripts/
# WHMAPI Tool
# by Webpods, LCC
# cyber@webpods.com
#####################
print qq~
WHMAPI Tool v1
--------
Usaage: whmapitool.pl list

~;

do_start();
sub do_start {
    # BEGIN CHOICE SELECTION
    print qq~
    ============================================================
		    WHMAPITool v1
    ============================================================
    -> Choose carefully?

    [ 1 ] cPanel User Temp Session
    [ 2 ] Root WHM Sessions
    [ 3 ] List Installed PHP Vhosts
    [ 4 ] List cPanel Version
    [ 5 ] Tweak Settings
    [ 6 ] Run Update
    [ 0 ] Exit...

    Your choice (0 to 6): ~;

    chomp ($choice=<STDIN>);
}

if ($choice eq '0') {
	exit 0;
}

elsif ($choice eq '1') {
    print qq~ Enter cPanel username: ~;
    chomp ($user=<STDIN>);
    cptemp();
}
elsif ($choice eq '2') {
    print qq~ Creating Root Session ~;
    whmroot();
}




# Login Section

# Setup a cPanel user session

sub cptemp {
system("/usr/sbin/whmapi1 create_user_session user=$user service=cpaneld locale=en|grep -Po '(?<=(url: )).*'")
	}

# Setup a WHM root session
sub whmroot {
system("/usr/sbin/whmapi1 create_user_session user=root service=whostmgrd locale=en|grep -Po '(?<=(url: )).*'")
}

#Vhost Type stuff
sub phpvhost {

system("/usr/sbin/whmapi1 php_get_vhost_versions")

	}
