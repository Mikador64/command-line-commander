# Perl Command Line Manager

This script is a Perl-based command-line manager, designed for managing and executing a variety of commands in an interactive and user-friendly way. It's a great tool for users who frequently work with command-line interfaces and need an organised, automated approach to handle their commands.

### Version:
0.01-2023

### Usage:

```
# script file needs ot be formated as a valid perl structure
clc.pl [script file]
```

To use this script, simply run it from the command line. It requires a configuration file with a list of commands to be passed as an argument. The script then reads this file and presents an interactive menu to the user.

### Config Structure:

```
[
	'Test Commands',
	{ title=>'Directory list', cmd=>'ls -lha'  },
	{ title=>'System info', cmd=>'neofetch'  },
	{ title=>'Drive info', cmd=>'df -h /'  },
	{ title=>'Perl test', cmd=>'perl -E \'say q|hi!|;\''  },
]
```

### Features:

- **Interactive Main Menu:** Offers a user-friendly interface for selecting and executing commands.
- **Automatic Command Execution:** Automatically runs a sequence of predefined commands, starting from a specified position.
- **Dynamic Command Navigation:** Enables users to directly jump to specific commands.
- **On-Screen Typewriter Effect:** Enhances the user interface with a typewriter-like effect for displaying text.
- **Customizable Command List:** The script reads a list of commands from an external configuration file, making it highly customizable.
- **Colored Text Output:** Uses ANSI colors to enhance the readability and visual appeal of the output.

### Technical Details:

- **Pragmas & Modules:** Utilizes Perl pragmas and modules like `List::Util`, `Term::ANSIColor`, and `Data::Dumper` for enhanced functionality.
- **Global Variables and Configuration:** Employs global variables for data handling and configures `Data::Dumper` for prettier output.
- **Subroutines:** Includes various subroutines like `mainMenu`, `autoCmds`, and `typeWriter` for different functionalities.
- **User Input Handling:** Processes user input for navigation and command execution.
- **Screen Management:** Implements functions to clear the screen and manage the display.


