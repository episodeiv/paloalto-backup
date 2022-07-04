# paloalto-backup

Receives a configuration backup from Paloalto firewalls and stores it in a git repository.

## Installation
- Install the Perl package manager `carton`
- Use `carton install` to install all required dependencies

## Configuration
`pa-backup` needs a configuration file named `config.yaml`. A sample is provided in this repository.

### API Keys
Paloalto firewalls support the generation and usage of API keys for various operations. These
keys are, however, relatively short-lived. To save you the hassle of updating the configuration
file every couple of days (hours?), you can alternatively provide a username and a password for
a user on your firewall(s). This user has to have superuser privileges but can (and should) have
only readonly permissions.
If you then set `generate_api_key` to `true`, `pa-backup` will fetch an API key on every run.

## Usage
- Create the directory to use as your configuration repository
- `git init` in that directory
- If you wish to push the configuration changes to another repository, add a remote
- Use `carton exec ./pa-backup.pl` to run the script
