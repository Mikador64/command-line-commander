#!/usr/bin/env perl

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INFO

#  COMMAND LINE COMMADER
#  by: 4d696b65.com
# url: https://hardfloppy.com/4d696b65/
# ver: v0.02-2023

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRAGMAS

use Term::ANSIColor qw|:constants|;
use File::HomeDir;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ DIR-CHECK

CHECK_FOLDER:

my $homeDir = File::HomeDir->my_home.'/git/command-line-commander/';

unless (-e $homeDir)
{
    print RED BOLD qq|> clc.pl needs to exist here: $homeDir\n|, RESET;
    exit 1;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PM

use lib File::HomeDir->my_home.'/git/command-line-commander/';
require 'clc-functions.pm';

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GLOBALS

$|++;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INPUT

ARGS:

unless (scalar @ARGV == 1 and -f $ARGV[0])
{
    print RESET;
    CLC::typeWriter('> ');
    CLC::quitNow('No config file so quitting!');
}

unless (CLC::overmind('eval-data',join('', <>)))
{
    CLC::quitNow(q|Can't create $data structure so bailing! :(|)
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CREDITS

AUTHOR:

my $data = CLC::overmind('get-data');

# author info
my $aboutName  = 'Command Line Manager';
my $aboutEmail = 'By: Mikador64.com';

CLC::clearScreen();
# display author flare
CLC::borderMenu();
print GREEN BOLD;
CLC::typeWriter($aboutName, 1);
CLC::typeWriter($aboutEmail, 1);
CLC::typeWriter('['.$$data[0].']', 1);
print RESET;
CLC::borderMenu();

CLC::pressEnter();

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MAIN-MENU

MENU:

CLC::overmind('reset-clc');
my $data = CLC::overmind('get-data');

CLC::clearScreen();
CLC::borderMenu();
CLC::listCmds();
CLC::borderMenu();

# ~~~~~~~~~~~~~~
MAIN_MENU:
# ~~~~~~~~~~~~~~

print YELLOW BOLD;
CLC::typeWriter('#)');
print RESET;
CLC::typeWriter(' Automatic start at postion ',1);
print YELLOW BOLD;
CLC::typeWriter('G)');
print RESET;
CLC::typeWriter(' Goto command  ');
print YELLOW BOLD;
CLC::typeWriter('Q)');
print RESET;
CLC::typeWriter(' Quit', 1);
CLC::borderMenu();


CLC::typeWriter('> Choice ~> ');
chomp(my $choice = <STDIN>);

if ($choice =~ m~^G$~i)
{
    # ~~~~~~~~~~~~~~
    GOTO:
    # ~~~~~~~~~~~~~~

    CLC::overmind('reset-clc');

    my $data = CLC::overmind('get-data');

    CLC::clearScreen();
    CLC::borderMenu();
    CLC::listCmds();
    CLC::borderMenu();

    CLC::typeWriter('> Which command? ~> ');
    chomp(my $choice = <STDIN>);

    if ($choice =~ m~Q|^$~i)
    {
        goto MENU;
    }

    if ($$data[$choice])
    {
        # CLC::overmind('set-clc', { preview => 1 } );
        my $clc = $$data[$choice];

        $$clc{stop} = undef;
        $$clc{preview} = 1;

        CLC::overmind('set-clc', $clc );
        my $return = CLC::runCmd(3);

        if ($return)
        {
            eval qq|goto ${return}|
        }

        CLC::pressEnter();
        CLC::clearScreen();
        goto GOTO;
    }
    else
    {
        goto GOTO;
    }

    goto GOTO;
}

if ($choice =~ m~^Q$~i)
{
    print RESET;
    CLC::typeWriter('> ');
    CLC::quitNow('Bye bye time!');
}

if ($choice == 0)
{
    CLC::clearScreen();
    goto MENU;
}
elsif ($choice == 1)
{
    CLC::autoCmds(1);
}
elsif ($choice =~ m~^\d+$~ && $$data[$choice] && $choice > 1)
{
    CLC::autoCmds($choice);
}
else
{
    CLC::quitNow('Command out of bounds!') unless $$data[$choice];
}

CLC::clearScreen();
goto MENU;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END

__END__
