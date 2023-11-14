#!/usr/bin/perl -i.bak -0777 -p

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRAGMAS

use feature qw|say|;
use Cwd;
use Term::ANSIColor qw|:constants|;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ BEGIN

BEGIN
{
    push @ARGV, $ENV{'HOME'}.'/.bashrc';
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INIT

$dir = getcwd();

$_.=qq|export PATH=${dir}:\$PATH\n|;
$_.=qq|alias clc="${dir}/clc.pl"\n|;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END

END
{
    say q|> |, UNDERLINE GREEN $dir, RESET q| added to .bashrc $PATH|;
}


