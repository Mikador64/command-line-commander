#!/usr/bin/env perl -i.bak -0777 -p

use feature qw|say|;
use Cwd;
use Term::ANSIColor qw|:constants|;

BEGIN { push @ARGV, $ENV{'HOME'}.'/.bashrc'; }

$dir = getcwd();

$_.=qq|export PATH=$dir:\$PATH\n|;

END { say q|> |, UNDERLINE GREEN $dir, RESET q| added to .bashrc $PATH|; }


