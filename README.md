# Command Line Commander

The Command Line Commander (CLC) is an interactive command-line tool designed for managing and executing various commands in a Unix-like environment. It offers a user-friendly interface, allowing users to efficiently handle command-line tasks with ease.

---

### Version
0.01-2023

---

### Repository Structure

- `/scripts`: Contains the main Perl scripts for CLM.
- `/docs`: Detailed documentation for each script.
- `/config_samples`: Sample configuration files.

---

### Scripts Overview

- `clc.pl`: The core script providing the command-line interface.
- `clc-create-config.pl`: Utility to create configuration files for `clc.pl`.
- `clc-setup.pl`: Sets up the environment for integrating `clc.pl` with the bash shell.

---

### Usage

To use CLM, run `clc.pl` with a configuration file:

```bash
clc.pl [config file]
```

The configuration file should be structured as follows:

```perl
[
    'Category Title',
    { title => 'Command Title', cmd => 'actual_command' },
    ...
]
```

---

### Features

- **Interactive Menu**: Easy selection and execution of commands.
- **Automatic Command Execution**: Execute a sequence of predefined commands.
- **Dynamic Navigation**: Jump directly to specific commands.
- **On-Screen Typewriter Effect**: For aesthetic text display.
- **Customizable Command List**: Via external configuration files.
- **Colored Text Output**: For enhanced readability.

---

### Technical Details

- **Modules**: Uses `Term::ANSIColor`, `Data::Dumper`, and more.
- **Subroutines**: Includes `mainMenu`, `autoCmds`, and `typeWriter`.
- **User Input Handling**: For navigation and command execution.
- **Screen Management**: Clear screen and manage display.

---

### Installation and Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Mikador64/command-line-commander
   ```

2. **Run the Setup Script** (for bash integration):
   ```bash
   perl clc-setup.pl
   ```

3. **Create a Config File**:
   ```bash
   perl clc-create-config.pl commands.txt > my_commands.cfg
   ```

4. **Run the Main Script**:
   ```bash
   perl clc.pl my_commands.cfg
   ```


