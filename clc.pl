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

my $data = [];
$|++;

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

$new = Dumper $data;
my $multi = eval $new;

MENU:
{
    listCmds();
    say '';
    mainMenu();
    typeWriter('> Choice ~> ');
    chomp(my $choice = <STDIN>);

    gotoCmds() if $choice =~ m~^G$~i;
    exit       if $choice =~ m~^Q$~i;

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUBS

sub quitNow($)
{
    my $quit = shift;
    print RED BOLD;
    typeWriter($quit, 1);
    print RESET;
    exit 1;
}

# clear screen
sub clearScreen()
{
    # Clears the entire screen
    print "\033[2J";
    # Moves the cursor to the top left corner
    print "\033[0;0H";
}

# main menu
sub mainMenu()
{
    print YELLOW BOLD;
    typeWriter('#)');
    print RESET;
    typeWriter(' automatic start at postion ',1);
    print YELLOW BOLD;
    typeWriter('g)');
    print RESET;
    typeWriter(' goto command  ');
    print YELLOW BOLD;
    typeWriter('q)');
    print RESET;
    typeWriter(' quit', 1);
    typeWriter('~'x45, 1);
}

# main menu
sub cmdMenu()
{
    print YELLOW BOLD;
    typeWriter('r)');
    print RESET;
    typeWriter(' run command ');
    print YELLOW BOLD;
    typeWriter('m)');
    print RESET;
    typeWriter(' back to menu', 1);
    typeWriter('~'x45, 1);
}

# press enter
sub pressEnter
{

    print YELLOW;
    typeWriter('> Press enter to continue...'),
    print RESET;
    <STDIN>;
}

sub continueCMD($)
{
    my $cmd = shift;

    cmdMenu();

    typeWriter('> Choice ~> ');
    chomp(my $choice = <STDIN>);

    system $cmd if $choice =~ m~^R$~i;

    if ($choice =~ m~^M$|^$~i)
    {
        clearScreen();
        goto MENU;
    }
}

sub listCmds
{
    my $cmd;
    for my $key (keys @{$data})
    {
        next if $key == 0;
        my $cmd = sprintf "%-2d -- %s", $key, $$data[$key]{title};
        typeWriter($cmd, 1);
    }
}

sub autoCmds
{
    my $start = shift;
    my $cmd;

    $start = 0 unless $start;

    for my $key (keys @{$data})
    {
        next if $key == 0;
        next if $key < $start;
        print RESET;
        typeWriter('> ');
        print GREEN BOLD UNDERLINE;
        $cmd = $$data[$key]{cmd};
        typeWriter($cmd, 1);
        sleep 3;
        print RESET;
        system $cmd;
    }

    pressEnter()
}

sub gotoCmds
{
    my $cmd;
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
        print GREEN;
        my $cmd = $$data[$choice]{cmd};
        typeWriter($cmd,1);
        print RESET;
        continueCMD($cmd);
    }
    else
    {
        goto COMMAND;
    }

   pressEnter();
}

# on screen typewriter effect
sub typeWriter($)
{
	shift =~ s`.`select(undef, undef, undef, rand(0.021)); print $&`ger;
	say '' if shift;
}

__END__
