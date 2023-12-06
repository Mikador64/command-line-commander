#!/usr/bin/env perl

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INFO

# by: mikador64.com
# email: hello-there@miker.media
# v0.01-2023

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRAGMAS

use Term::ANSIColor qw|:constants|;
use feature qw|say state|;
use File::HomeDir;
use Data::Dumper;
use warnings;
use strict;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CONFIG

# configure Data::Dumper for prettier output

# to ensure the dumped data remains valid perl code
$Data::Dumper::Purity   = 1;
# use a readable (indented) style
$Data::Dumper::Indent   = 1;
# sort harsh keys
$Data::Dumper::Sortkeys = 1;
# avoids $VAR1 = at the beginning of the dump
$Data::Dumper::Terse	= 1;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GLOBALS

$|++;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INPUT

ARGS:
{
    unless (scalar @ARGV == 1 and -f $ARGV[0])
    {
        print RESET;
        typeWriter('> ');
        quitNow('No config file so quitting!');
    }

    unless (overmind('eval-data',join('', <>)))
    {
        quitNow(q|Can't create $data structure so bailing! :(|)
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CREDITS

AUTHOR:
{
    my $data = overmind('get-data');

    # author info
    my $aboutName  = 'Command Line Manager';
    my $aboutEmail = 'By: Mikador64.com';

    clearScreen();
    # display author flare
    borderMenu();
    print GREEN BOLD;
    typeWriter($aboutName, 1);
    typeWriter($aboutEmail, 1);
    typeWriter('['.$$data[0].']', 1);
    print RESET;
    borderMenu();

    pressEnter();

    goto MENU;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ MAIN-MENU

MENU:
{
   overmind('reset-clc');
   my $data = overmind('get-data');

    clearScreen();
    borderMenu();
    listCmds();
    borderMenu();
    mainMenu();

    typeWriter('> Choice ~> ');
    chomp(my $choice = <STDIN>);

    goto MENU_GOTO if $choice =~ m~^G$~i;


    if ($choice =~ m~^Q$~i)
    {
        print RESET;
        typeWriter('> ');
        quitNow('Bye bye time!');
    }

    if ($choice == 0)
    {
        clearScreen();
        goto MENU;
    }
    elsif ($choice == 1)
    {
         autoCmds(1);
    }
    elsif ($choice =~ m~^\d+$~ && $$data[$choice] && $choice > 1)
    {
        autoCmds($choice);
    }
    else
    {
        quitNow('Command out of bounds!') unless $$data[$choice];
        autoCmds($choice);
    }

    clearScreen();
    goto MENU;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ GOTO-COMMANDS

MENU_GOTO:
{
    overmind('reset-clc');
    overmind('set-clc', { preview => 1 } );

    my $clc  = overmind('get-clc');
    my $data = overmind('get-data');

    clearScreen();
    borderMenu();
    listCmds();
    borderMenu();

    typeWriter('> Which command? ~> ');
    chomp(my $choice = <STDIN>);

    if ($choice =~ m~Q|^$~i)
    {
        goto MENU;
    }

    if ($$data[$choice])
    {
        $$clc{cmd}   = $$data[$choice]{cmd};
        $$clc{regex} = $$data[$choice]{regex} if $$data[$choice]{regex};

        runCmd(3);
        pressEnter();
        clearScreen();
        goto MENU_GOTO;
    }
    else
    {
        goto MENU_GOTO;
    }

    goto MENU_GOTO;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-OVERMIND

sub overmind
{
   # ~~~~~~~~~~~~~~~ STATE

    state $data = 'placeholder';
    state $clc  = bless
    {
        title => '',
        cmd   => '',
        regex => '',
        preview => 0,

    }, 'clc';

    # ~~~~~~~~~~~~~~~ DO

    my $do  = shift;
    my $var = shift;

    if ($do eq 'eval-data')
    {
        $data = eval $var;
        return 1;
    }
    elsif ($do eq 'get-data')
    {
        return $data;
    }
    elsif ($do eq 'set-clc')
    {
        $$clc{title}    = $$var{title}      // $$clc{title};
        $$clc{cmd}      = $$var{cmd}       // $$clc{cmd};
        $$clc{regex}    = $$var{regex}    // $$clc{regex};
        $$clc{preview}  = $$var{preview} // $$clc{preview};

        return 1;
    }
    elsif ($do eq 'get-clc')
    {
        return $clc;
    }
    elsif ($do eq 'reset-clc')
    {
        $clc =
        {
            title => '',
            cmd   => '',
            regex => '',
            preview => 0
        };

        return 1;
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-LIST-CMDS

sub listCmds
{
    my $data = overmind('get-data');

    for my $key (keys @{$data})
    {
        next if $key == 0;
        printf "%-2d -- %s\n", $key, $$data[$key]{title};
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-AUTO-CMDS

sub autoCmds($)
{
    my $start = shift;
    my $data = overmind('get-data');

    overmind('reset-clc');
    my $clc = overmind('get-clc');

    $start = 0 unless $start;

    for my $key (keys @{$data})
    {
        next if $key == 0;
        next if $key < $start;

        $$clc{cmd}   = $$data[$key]{cmd};
        $$clc{regex} = $$data[$key]{regex} if $$data[$key]{regex};

        runCmd(3);
    }

    pressEnter()
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-GOTO-CMD

# pause command
sub continueCmd
{
    continueMenu();

    print q|> Choice ~> |;
    chomp (my $choice = <STDIN>);

    # Quit to main menu
    if ($choice =~ m~^Q$~i)
    {
        goto MENU;
    }
    # Run command
    elsif ($choice =~ m~^R$~i)
    {
        # Continue commands...
    }
    elsif ($choice =~ m~^M$~i)
    {
        goto MENU_GOTO;
    }
    else # enter
    {
        goto MENU_GOTO;
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-RUN-CMD

sub runCmd()
{
    my $sleep = shift // 0;
    my $clc   = overmind('get-clc');

    say Dumper $clc;

    if ($$clc{regex})
    {
        my $homeDir = File::HomeDir->my_home;
        my $config = $$clc{regex} =~ s`~`$homeDir`r;

        if (-f $config)
        {
            open my $fh, '<', $config or quitNow(qq|Missing regex file: <${config}> so quitting!|);

            while (<$fh>)
            {
                chomp;
                next if m`^$|^#`;
                my $reRun = qq|\$\$clc{cmd} =~ ${_};|;
                eval $reRun;
            }

            close $fh;
        }
    }

    print RESET;
    typeWriter('> ');
    print BOLD GREEN;
    typeWriter($$clc{cmd},1);
    print RESET;

    continueCmd() if $$clc{preview} == 1;

    sleep $sleep;

    system $$clc{cmd};
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-TUI-MENUS

# main menu
sub mainMenu
{
    print YELLOW BOLD;
    typeWriter('#)');
    print RESET;
    typeWriter(' Automatic start at postion ',1);
    print YELLOW BOLD;
    typeWriter('G)');
    print RESET;
    typeWriter(' Goto command  ');
    print YELLOW BOLD;
    typeWriter('Q)');
    print RESET;
    typeWriter(' Quit', 1);
    borderMenu()
}

sub continueMenu
{
    borderMenu();
    print YELLOW BOLD;
    typeWriter('R)');
    print RESET;
    typeWriter(' Run command ');
    print YELLOW BOLD;
    typeWriter('M)');
    print RESET;
    typeWriter(' Goto command menu  ',1);
    print YELLOW BOLD;
    typeWriter('Q)');
    print RESET;
    typeWriter(' Quit to main menu',1);
    borderMenu();
}

# border menu
sub borderMenu()
{
    say '─'x70;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-QUIT

sub quitNow($)
{
    my $quit = shift;
    print RED BOLD;
    typeWriter($quit, 1);
    print RESET;
    exit 1;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-SCREEN-FX

# clear screen
sub clearScreen
{
    # clears the entire screen
    print "\033[2J";
    # moves the cursor to the top left corner
    print "\033[0;0H";
}

# press enter
sub pressEnter
{
    print YELLOW;
    typeWriter('> Press enter to continue...'),
    print RESET;
    <STDIN>;
}

# on screen typewriter effect
sub typeWriter($)
{
    shift =~ s`.`select(undef, undef, undef, rand(0.021)); print $&`ger;
    say '' if shift;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END

__END__
