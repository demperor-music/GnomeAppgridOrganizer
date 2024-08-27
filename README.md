# GnomeAppgridOrganizer
[Demonstration](https://github.com/user-attachments/assets/75f5b34a-9291-4387-a821-5eb8fd3afd5a)


GnomeAppgridOrganizer is a shell script that helps you organize your GNOME desktop application grid by categorizing your applications into folders.

## Features

- Create custom folders in the GNOME application grid
- Use recommended folder structure or create your own
- Dry-run mode to preview changes without applying them
- Option to print the generated configuration
- Quiet mode for silent operation
- Read configuration from pipe input

## Requirements

- GNOME desktop environment
- `gsettings` command-line tool

## Usage

```
./gnome-appgrid-organizer.sh [OPTIONS]
```

### Options

- `-d, --dry-run`: Perform a dry run without making any changes
- `-r, --recommended`: Use recommended folders without asking for user input
- `-p, --print-config`: Print the generated configuration at the end
- `-q, --quiet`: Suppress output messages

### Examples

1. Create recommended folders:
   ```
   ./gnome-appgrid-organizer.sh -r
   ```

2. Perform a dry run and print configuration:
   ```
   ./gnome-appgrid-organizer.sh -dp
   ```

3. Create recommended folders quietly:
   ```
   ./gnome-appgrid-organizer.sh --quiet --recommended
   ```

4. Read configuration from pipe:
   ```
   ./gnome-appgrid-organizer.sh < input.txt
   ```

## Custom Folder Configuration

If you don't use the recommended folder structure, you can create custom folders by providing the following information for each folder:

1. Folder name
2. Categories (comma-separated)
3. Display name

Enter `[END]` when you're done.

## Recommended Folder Structure

When using the `-r` or `--recommended` option, the script creates the following folder structure:

- Games
- Utility
- Office
- Development
- System
- Social
- Internet
- Media
- Graphics

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Disclaimer

This script modifies your GNOME desktop configuration. While it's designed to be safe to use, please ensure you have a backup of your configuration before running it.
