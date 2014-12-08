#!/usr/bin/perl

use strict;
use warnings;
use autodie;

use File::Spec::Functions qw(:ALL);

# get what popclip passed us
my $input = $ENV{POPCLIP_TEXT};
chomp $input;

# break the passed text of the form "something at line 1234"
# into line numbers and path
my ($path,$lineno) = $input =~ m/\Aat (.*) line (\d+)\z/;

unless (file_name_is_absolute($path)) {
	$path = rel2abs($path,terminal_cwd());
}

# okay this is the combined filename we want to open.
my $what = "$path:$lineno";

# and open it with the editor
exec(subl(),$what);

########################################################################

# what's the tty of the front most terminal
sub terminal_tty {
	my $tty = `osascript -e 'tell application "Terminal" to tty of front tab of front window'`;
	chomp $tty;
	return $tty;
}

# what processes are running for a given tty?
sub terminal_pids {
	open my $pfh, "-|", "ps","-f","-t", shift;
	my %pids;
	<$pfh>; # ignore header
	while (<$pfh>) {
		chomp;
		s/\A\s+//;
		my ($UID,$PID,$PPID,$C,$STIME,$TTY,$TIME,$CMD) =
			split /\s+/, $_, 8;
		$pids{ $PID } = {
			pid => $PID,
			parent => $PPID,
			cmd => $CMD,
			children => [],
		}
	}

	my %output = %pids;
	foreach my $pid (keys %pids) {
		push @{ $pids{ $pids{ $pid }{parent} }{children} }, delete $output{ $pid }
			if exists $pids{ $pids{ $pid }{parent} };
	}

	return (values %output)[0]
}

# guess what the best pid is
sub find_best_pid {
	my $output = shift;
	my ($pid) = _find_best_pid($output,0);
	return $pid;
}

# find the deepest bash
sub _find_best_pid {
	my $output = shift;
	my $level = shift;

	my $best_pid;
	my $best_level = -1;

	if ($output->{cmd} =~ /\A-?bash/) {
		$best_pid = $output->{pid};
		$best_level = $level;
	}

	foreach my $child (@{ $output->{children} }) {
		my ($child_best_pid, $child_best_level) = _find_best_pid( $child, $level + 1 );
		if ($child_best_pid && $child_best_level > $best_level) {
			($best_pid, $best_level) = ($child_best_pid, $child_best_level);
		}
	}

	return ($best_pid, $best_level);
}

# what is the pid 
sub pid_cwd {
	my $pid = shift;
	die "Invalid pid '$pid'" unless $pid =~ /\A[0-9]+\z/;

	my @data = `/usr/sbin/lsof -a -p $pid -d cwd -n 2>/dev/null`;
	my $cwd = (split " ", $data[-1], 9)[-1];
	chomp $cwd;

	return $cwd;
}

# work out what the pwd of the front most terminal is
sub terminal_cwd {
	my ($pids) = terminal_pids( terminal_tty() );
	return pid_cwd( find_best_pid( $pids ) );
}

# work out what the path to Sublime Text is
sub subl {
	my $s = `osascript -e 'POSIX path of (path to app "Sublime Text")' 2>/dev/null`
	     || `osascript -e 'POSIX path of (path to app "Sublime Text 3")' 2>/dev/null`
	     || `osascript -e 'POSIX path of (path to app "Sublime Text 2")' 2>/dev/null`
	     or die "Can't find subl!";
	chomp $s;
	return $s.'Contents/SharedSupport/bin/subl';
}
