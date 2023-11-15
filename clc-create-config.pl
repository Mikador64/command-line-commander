#!/usr/bin/env perl

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INFO

# by: mikador64.com
# email: hello-there@miker.media
# v0.01-2023

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRAGMAS

use utf8;
use feature qw|say|;
use Term::ANSIColor qw(:constants);
use Data::Dumper;

# use JSON::XS;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CONFIG

# configure Data::Dumper for prettier output
$Data::Dumper::Purity   = 1;  # to ensure the dumped data remains valid Perl code
$Data::Dumper::Indent   = 1;  # use a readable (indented) style
$Data::Dumper::Sortkeys = 1;  # sort harsh keys
$Data::Dumper::Terse	= 1;  # avoids $VAR1 = at the beginning of the dump

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GLOBALS

my $data = [];
my $n = 0;

$|++;

my $type = 0;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CHECK

if (scalar @ARGV == 1)
{
    $type = 1;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INIT

LOOP:
{
    $_ = read_line();
    chomp $_;
    last LOOP unless $_;
    # next LOOP if m~^$~;
    # next LOOP if m~^#~;

    if (m~^>\s+(.*)$~)
    {
        $$data[$n] = $1;
    }
    elsif(m~^(title)=(.*)$~i)
    {
       $n++;
       $$data[$n]{$1} = $2;
    }
    elsif(m~^(regex|cmd)=(.*)$~i)
    {
        $$data[$n]{$1} = $2;
    }

    goto LOOP;
}

say Dumper $data;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUBS

sub read_line
{
    return <> if scalar $type;
    return <DATA>;
}

# ║
__END__
> Test
# List Test
title=List Folders
cmd=ls -lha *.EXT
regex=./regex.txt
# DF Test
title=Test DF
cmd=df -h /
