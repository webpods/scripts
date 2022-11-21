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


# Login Section

# Setup a cPanel user session

sub cptemp {
system("/usr/sbin/whmapi1 create_user_session user=$user service=cpaneld locale=en|grep -Po '(?<=(url: )).*'")
	}

# Setup a WHM root session
sub whmroot {
system("whmapi1 create_user_session user=root service=whostmgrd locale=en preferred_domain=$(/bin/hostname -i) | grep -Po '(?<=(url: )).*'")
}

#Vhost Type stuff
sub phpvhost {

system("/usr/sbin/whmapi1 php_get_vhost_versions")

	}
