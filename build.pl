#!/usr/bin/perl -s

use strict;
use warnings;

use Archive::Zip qw( :ERROR_CODES :CONSTANTS );
use File::Copy qw(move);

my $zip = Archive::Zip->new();

my $script = $zip->addFile( "script.pl", 'PerlErrorSublime.popclipext/script.pl' );
$script->desiredCompressionMethod( COMPRESSION_DEFLATED );

my $plist = $zip->addFile( "Config.plist", 'PerlErrorSublime.popclipext/Config.plist' );
$plist->desiredCompressionMethod( COMPRESSION_DEFLATED );

my $png = $zip->addFile( "logo.png", 'PerlErrorSublime.popclipext/logo.png' );
$png->desiredCompressionMethod( COMPRESSION_DEFLATED );

unless ( $zip->writeToFileNamed( 'PerlErrorSublime.popclipextz' ) == AZ_OK ) {
    die 'Cannot create zipfile containing extension';
}

if ($::d && $::d) {
    move(
      'PerlErrorSublime.popclipextz',
      "$ENV{HOME}/Dropbox/Public/popclip/PerlErrorSublime.popclipextz"
    ) or die "Couldn't move!";
}

=head1 NAME

build.pl - create a PerlErrorSublime.popclipextz file

=head1 SYNOPSIS

   # create in directory
   ./build.pl

   # create in directory and then move to ~/Dropbox/Public/popclip
   ./build.pl -d