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

}, 'clc';

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INPUT

unless (scalar @ARGV == 1 and -f $ARGV[0])
{
    quitNow('No config file so quitting!');
}

$data = eval(join('', <>));

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ CREDITS

# author info
my $aboutName  = 'Command Line Manager';
my $aboutEmail = 'By: Mikador64.com';

clearScreen();
# display author flare
print GREEN BOLD;
typeWriter($aboutName, 1);
typeWriter($aboutEmail, 1);
typeWriter('['.$$data[0].']', 1);
print RESET;
typeWriter('~'x45, 1);

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ INIT

MENU:
{
    listCmds();
    say '';
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

    if ($choice == 1)
    {
         autoCmds(1);
    }
    elsif ($choice =~ m~^\d+$~ && $choice > 1)
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

    $$cli{cmd}   = '';
    $$cli{regex} = '';

    $start = 0 unless $start;

    for my $key (keys @{$data})
    {
        next if $key == 0;
        next if $key < $start;

        $$cli{cmd}   = $$data[$key]{cmd};
        $$cli{regex} = $$data[$choice]{regex} if $$data[$choice]{regex};

        runCmd(3);
    }

    pressEnter()
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-GOTO-CMD

sub gotoCmds
{
    $$cli{cmd}   = '';
    $$cli{regex} = '';

    my $loc  = 1;
    COMMAND: typeWriter('> Which command? ~> ');
    chomp(my $choice = <STDIN>);

    if ($choice =~ m~Q|^$~i)
    {
        clearScreen();
        goto MENU;
    }

    if ($$data[$choice])
    {
        $$cli{cmd}   = $$data[$choice]{cmd};
        $$cli{regex} = $$data[$choice]{regex} if $$data[$choice]{regex};

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-RUN-CMD

sub runCmd()
{
    my $sleep = shift // 0;

    if ($$clc{regex} && -f $$clc{regex})
    {
        open my $fh, '<', $$clc{regex} or quitNow(qq|Missing regex file: <$$clc{regex}> so quitting!|);

        while (<$fh>)
        {
            chomp;
            next if m`^$|^#`;
            my $reRun = qq|\$cmd =~ ${_};|;
            eval $reRun;
        }
    }

    print RESET;
    typeWriter('> ');
    print BOLD GREEN UNDERLINE;
    typeWriter($$cli{cmd},1);
    print RESET;

    sleep $sleep;

    system $$cli{cmd};

    $$cli{cmd}   = '';
    $$clc{regex} = '';
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
    typeWriter('g)');
    print RESET;
    typeWriter(' Goto command  ');
    print YELLOW BOLD;
    typeWriter('q)');
    print RESET;
    typeWriter(' Quit', 1);
    typeWriter('~'x45, 1);
}

# border menu
sub borderMenu()
{
    typeWriter('~'x45, 1);
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

# on screen typewriter effect
sub typeWriter($)
{
    shift =~ s`.`select(undef, undef, undef, rand(0.021)); print $&`ger;
    say '' if shift;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END

__END__
