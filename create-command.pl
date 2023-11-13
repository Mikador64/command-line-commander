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

while (my $line = read_line())
{
    next if $line =~ m~^$~;
    next if $line =~ m~^#~;

    chomp $line;

    if ($n == 0)
    {
        $$data[$n] = $line;
    }
    else
    {
        $$data[$n] =
        {
            title => ${[ split m`>>>`, $line ]}[0],
            cmd   => ${[ split m`>>>`, $line ]}[1]
        };
    }

    $n++;
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

