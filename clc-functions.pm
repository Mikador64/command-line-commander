#!/usr/bin/env perl

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PACKAGE

package CLC;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ PRAGMAS

use Term::ANSIColor qw|:constants|;
use feature qw|say state|;
use File::HomeDir;
use Data::Dumper;

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

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-OVERMIND

sub overmind
{
   # ~~~~~~~~~~~~~~~ STATE

    state $data = 'placeholder';
    state $clc  = bless
    {
        title => '',
        cmd   => '',
        stop  => 0,
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
        $$clc{title}    = $$var{title}       // $$clc{title};
        $$clc{stop}     = $$var{stop}       // $$clc{stop};
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
            stop  => 0,
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
    # my $clc = overmind('get-clc');

    $start = 0 unless $start;

    for my $key (keys @{$data})
    {
        next if $key == 0;
        next if $key < $start;

        overmind('set-clc', $$data[$key] );

        my $response = runCmd(3);

        return $response if $response;

    }

    pressEnter()
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-RUN-CMD

sub runCmd()
{
    my $sleep = shift // 0;
    my $clc   = overmind('get-clc');

    # say Dumper $clc; # Debug

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

    if ($$clc{preview} == 1)
    {
        # Continue Menu
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

        print q|> Choice ~> |;
        chomp (my $choice = <STDIN>);

        # Quit to main menu
        if ($choice =~ m~^Q$~i)
        {
            return 'MENU';
        }
        # Run command
        elsif ($choice =~ m~^R$~i)
        {
            # Continue commands...
        }
        elsif ($choice =~ m~^M$~i)
        {
            return 'MENU_GOTO';
        }
        else # enter
        {
            return 'MENU_GOTO';
        }

    }

    sleep $sleep;

    system $$clc{cmd};

    if ($$clc{stop})
    {
        print YELLOW BOLD;
        say q|> STOP command detected returing to main menu...|;
        print RESET;
        pressEnter();
        return 'MAIN';
    }
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SUB-TUI-MENUS

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
sub typeWriter
{
    shift =~ s`.`select(undef, undef, undef, rand(0.021)); print $&`ger;
    say '' if shift;
}

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ END

1;
