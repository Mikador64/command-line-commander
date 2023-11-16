#!/usr/bin/env perl

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INFO

# by: mikador64.com
# email: hello-there@miker.media
# v0.01-2023

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRAGMAS

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

$|++;
my $data = [];
my $clc  = bless
{
    title => '',
    cmd   => '',
    regex => '',
    preview => 0,

}, 'clc';

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INPUT

unless (scalar @ARGV == 1 and -f $ARGV[0])
{
    print RESET;
    typeWriter('> ');
    quitNow('No config file so quitting!');
}

$data = eval(join('', <>));

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CREDITS

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INIT

MENU:
{
    borderMenu();
    listCmds();
    borderMenu();
    mainMenu();
    typeWriter('> Choice ~> ');
    chomp(my $choice = <STDIN>);

    gotoCmds() if $choice =~ m~^G$~i;


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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-LIST-CMDS

sub listCmds
{
    my $cmd;
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

    $$clc{cmd}   = '';
    $$clc{regex} = '';
    $$clc{preview} = 0;

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

sub gotoCmds
{
    $$clc{cmd}   = '';
    $$clc{regex} = '';
    $$clc{preview} = 1;

    COMMAND:
    {
        typeWriter('> Which command? ~> ');
        chomp(my $choice = <STDIN>);

        if ($choice =~ m~Q|^$~i)
        {
            clearScreen();
            goto MENU;
        }

        if ($$data[$choice])
        {
            $$clc{cmd}   = $$data[$choice]{cmd};
            $$clc{regex} = $$data[$choice]{regex} if $$data[$choice]{regex};

            runCmd(3);
            pressEnter();
            clearScreen();
            listCmds();
            borderMenu();
            goto COMMAND;
        }
        else
        {
            goto COMMAND;
        }
    }

}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-RUN-CMD

sub runCmd()
{
    my $sleep = shift // 0;

    if ($$clc{regex})
    {
        my $homeDir = glob('~');
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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-MENUS

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
    # Clears the entire screen
    print "\033[2J";
    # Moves the cursor to the top left corner
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

# Pause command
sub continueCmd
{
    borderMenu();
    print YELLOW BOLD;
    typeWriter('C)');
    print RESET;
    typeWriter(' Run command ');
    print YELLOW BOLD;
    typeWriter('G)');
    print RESET;
    typeWriter(' Goto command menu  ',1);
    print YELLOW BOLD;
    typeWriter('M)');
    print RESET;
    typeWriter(' Quit to main menu',1);
    borderMenu();

    print q|> Choice ~> |;
    chomp (my $choice = <STDIN>);
    if ($choice =~ m~^M$~i)
    {
        clearScreen();
        goto MENU;
    }
    elsif ($choice =~ m~^G$~i)
    {
        clearScreen();
        listCmds();
        borderMenu();
        goto COMMAND;
    }
}

# on screen typewriter effect
sub typeWriter($)
{
    shift =~ s`.`select(undef, undef, undef, rand(0.021)); print $&`ger;
    say '' if shift;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END

__END__
