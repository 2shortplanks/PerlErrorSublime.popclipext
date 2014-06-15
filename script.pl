#!/usr/bin/perl

use strict;
use warnings;
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
system(subl(),$what);

# work out what the pwd of the front most terminal is
sub terminal_cwd {
	my @data = `/usr/sbin/lsof -a -p \$(ps -o pid -t \$(osascript -e 'tell application "Terminal" to tty of front tab of front window') | tail -n 1) -d cwd -n 2>/tmp/arrgh`;
	my $cwd = (split " ", $data[-1], 9)[-1];
	chomp $cwd;
	return $cwd;
}

# work out what the path to Sublime Text is
sub subl {
	my $s = `osascript -e 'POSIX path of (path to app "Sublime Text 3")' 2>/dev/null`
	     || `osascript -e 'POSIX path of (path to app "Sublime Text 2")' 2>/dev/null`
	     or die "Can't find subl!";
	chomp $s;
	return $s.'Contents/SharedSupport/bin/subl';
}
