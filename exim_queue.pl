#!/usr/bin/perl
# exim_queue.pl - Generates report of current exim queue in .. #
#a cpanel environment ....................... #

use File::Find;
use File::Spec;

my $frozen=0;			# Count of Frozen emails ...........# 
our (	%mails_per_user,	# No. of emails per Cpanel user ....#
	%failed_recepients,	# Bounced emails ...................#
	%subject,		# Email count per subject ..........#
	%mail_script_source,	# Script Source ....................#
	%from_email_address,	# Email count per email address ....#
	%msg_id_per_user,
	%msg_id_per_script,
	%msg_id_per_subject,
	%msg_id_per_from_email_address,
	@frozen_mails,
	@bounced_mails ) ;

my $mailq=`exim -bpc`;
chomp $mailq;

my ( $show_mails_per_user, 
     $show_failed_recepients,
     $show_subject,
     $show_mail_script_source,
     $show_from_email_address ) 
   = (1, 1, 1, 1, 1); # Change to 0 to ignore from generated report #

$mail_dir='/var/spool/exim/input';

find(\&wanted, $mail_dir);
print "\n\n";
print "                   EXIM MAIL QUEUE REPORT                   \n";
print "============================================================\n\n";
print "-> Total mails in Queue: $mailq \n";
print "-> No of frozen emails : $frozen";

if (%mails_per_user && $show_mails_per_user==1) { 
print "\n\n-> Emails per CPanel User:\n\n";
print " COUNT   USER\n";
print "----------------------------------\n";
printf "%5d   %s\n", $mails_per_user{$_}, $_ foreach sort keys %mails_per_user ; }

if (%failed_recepients && $show_failed_recepients==1) {
print "\n\n-> Mails to following email addresses got bounced:\n\n";
print " COUNT   EMAIL\n";
print "----------------------------------\n";
printf "%5d   %s\n", $failed_recepients{$_}, $_ foreach sort keys %failed_recepients ; }

if (%subject && $show_subject==1) {
print "\n\n-> Subject of emails in the mail queue:\n\n";
print " COUNT   SUBJECT\n";
print "----------------------------------\n";
printf "%5d   %s\n", $subject{$_}, $_ foreach sort keys %subject ; }

if (%mail_script_source && $show_mail_script_source==1) {
print "\n\n-> Scripts that sent mail (X-PHP-Script header):\n\n";
print " COUNT   SCRIPT\n";
print "----------------------------------\n";
printf "%5d   %s\n", $mail_script_source{$_}, $_ foreach sort keys %mail_script_source ; }

if (%from_email_address && $show_from_email_address==1) {
print "\n\n-> From address of mails in the mail queue:\n\n";
print " COUNT   FROM\n";
print "----------------------------------\n";
printf "%5d   %s\n", $from_email_address{$_}, $_ foreach sort keys %from_email_address ; }
print "\n\n============================================================";

my $choice;
print "\n\n-> What do you want to do?

 [1] Remove all mails of a Cpanel user
 [2] Remove all mails with specific subject
 [3] Remove all mails originated from a script source
 [4] Remove all bounced emails
 [5] Remove all frozen emails
 [6] Remove all mails From: specific email address
 [7] Chmod a script source to 000
 [8] I'm done! Exit...


Your choice (1 to 8) ->  ";
chomp ($choice=<STDIN>);
if ($choice==1)  {&rm_user_mails}
elsif ($choice==2) {&rm_specific_sub}
elsif ($choice==3) {&rm_script_source}
elsif ($choice==4) {&rm_bounced}
elsif ($choice==5) {&rm_frozen}
elsif ($choice==6) {&rm_per_from_email}
elsif ($choice==7) {&chmod_script}

sub chmod_script {
	my ($script_domain, $script_path, $domain_user, $script_file);
	print "\nEnter the script URL (from above report): ";
	chomp (my $script=<STDIN>);
	print "\n";
	$script =~ s/^(http:\/\/|https:\/\/)?www\.// ;
	if ($script =~ m#(.*?)/(.*)#) {
		$script_domain = $1;
		$script_path= $2;
	} 
	else {
		die "Seems to be invalid path! Exiting...\n";
	}
	open (USERDOMAINS, " </etc/userdomains") || die "Unable to open: $!\n";
	while (<USERDOMAINS>) {
		if (/^(?:$script_domain: )(.*)$/) {
			$domain_user = $1;
			last ;
		}
	}
	close USERDOMAINS;
	unless (defined $domain_user) {
	  die "Unable to find $script_domain in /etc/userdomains! Exiting...\n";
	}
	if ( $script_domain =~ /^(.*?)\.(.*?\..*)$/) {
	  $script_file = "/home/$domain_user/public_html/$1*/$script_path";
	}
	else {
	  $script_file = "/home/$domain_user/public_html/$script_path";
	}
	system ("chmod 000 $script_file -v");
	system ("chown root:root $script_file -v");
}

sub rm_per_from_email {
	print "\nEnter the From: email address from the above report: ";
	chomp (my $email=<STDIN>);
	if (exists $msg_id_per_from_email_address{$email}) {
	my @msgids=@{$msg_id_per_from_email_address{$email}} ;
	system ("exim -Mrm $_ 2>/dev/null") foreach (@msgids);
	print scalar @msgids , " messages originated From: '$email' removed!\n";
	}
}

sub rm_user_mails {
	print "\nEnter the Cpanel username (from above list): ";
	chomp (my $user=<STDIN>);
	if (exists $msg_id_per_user{$user}) {
		my @msgids=@{$msg_id_per_user{$user}};
		system ("exim -Mrm $_ 2>/dev/null") foreach (@msgids);
		print scalar @msgids , " messages of '$user' removed!\n";
	}
	else {
		print "\nInvalid User!!";
	}
}

sub rm_specific_sub {
        print "\nEnter the exact email subject (from above list): ";
        chomp (my $subject=<STDIN>);
        if (exists $msg_id_per_subject{$subject}) {
                my @msgids=@{$msg_id_per_subject{$subject}};
                system ("exim -Mrm $_ 2>/dev/null") foreach (@msgids);
                print scalar @msgids , " messages with subject '$subject' removed!\n";
        }
        else {
                print "\nInvalid subject!! Please try again";
        }
}

sub rm_script_source {
        print "\nEnter the exact script source (from above list): ";
        chomp (my $scr_src=<STDIN>);
        if (exists $msg_id_per_script{$scr_src}) {
                my @msgids=@{$msg_id_per_script{$scr_src}};
                system ("exim -Mrm $_ 2>/dev/null") foreach (@msgids);
                print scalar @msgids , " messages sent from '$scr_src' removed!\n";
        }
        else {
                print "\nInvalid script source!! Please try again";
        }
}

sub rm_bounced {
	system ("exim -Mrm $_ 2>/dev/null") foreach (@bounced_mails) ;
	print scalar @bounced_mails , " bounced messages removed from mail queue\n"
}

sub rm_frozen {
	system ("exim -Mrm $_ 2>/dev/null") foreach (@frozen_mails) ;
	print scalar @frozen_mails , " frozen messages removed from mail queue\n"
}

sub wanted {
	if (/-H$/) {
		my $file = File::Spec->catfile($File::Find::dir,$_) ;
		open (FILE, " <$file") || die "Cannot open file : $!";
		while (<FILE>) {
			chomp;
			$msg_id=$1 if /^(\S{6}-\S{6}-\S{2})-\S\s*/ ;
			if (/^-frozen/) {
				push @frozen_mails, $msg_id;
				$frozen++ ;
			}

			if (/^-ident (\S+)\s*$/) {
				$msg_id_per_user{$1} = [] unless exists $msg_id_per_user{$1};
				$mails_per_user{$1}++ ;
				push @{$msg_id_per_user{$1}}, $msg_id ;
			}

			if (/Subject: (.*)$/) {
				$msg_id_per_subject{$1} = [] unless exists $msg_id_per_subject{$1};
				$subject{$1}++ ;
				push @{$msg_id_per_subject{$1}}, $msg_id ;
			}

			if (/X-PHP-Script: (\S+?)\s/) {
				$msg_id_per_script{$1} = [] unless exists $msg_id_per_script{$1};
				$mail_script_source{$1}++ ;
				push @{$msg_id_per_script{$1}}, $msg_id ;
			}

			$failed_recepients{$1}++ if /X-Failed-Recipients:.*?(?:<)?(\S+\@\S+?)(?:>)?\s*$/ ;
			push @bounced_mails, $msg_id if /X-Failed-Recipients:.*?(?:<)?(\S+\@\S+?)(?:>)?\s*$/ ;
			if (/From:.*?(?:<)?(\S+\@\S+?)(?:>)?,?\s*$/) {
				$from_email_address{$1}++ ;
				my $match = $1 ;
				$msg_id_per_from_email_address{$match} = [] unless exists $msg_id_per_from_email_address{$match};
				push @{$msg_id_per_from_email_address{$match}}, $msg_id ;
			}
		}
		close FILE;
	}
}
print "\n\n============================================================\n\n";
# -------------------------- END -------------------------- #
