# Run command at intervals

This bash script allows you to run commands at specified intervals, with optional sleep prevention.

## Features
- Run any command at regular intervals
- Prevent system sleep during command execution (macOS and Linux)
- Log command output and execution times

## Usage

```bash
./run_in_intervals.sh [--interval=MINUTES] [--no-sleep] COMMAND
```


### Options

- `--interval=MINUTES`: Set the interval between command executions (default: 30 minutes)
- `--no-sleep`: Prevent system sleep during command execution (requires `caffeinate` on macOS or `caffeine` on Linux)
- `COMMAND`: The command to be executed at each interval

### Examples

Run a backup script every hour:

```bash
./run_in_intervals.sh --interval=60 --no-sleep "backup_script.sh"
```

Check for updates every 15 minutes, preventing sleep:

```bash
./run_in_intervals.sh --interval=15 --no-sleep "check_for_updates.sh"
```

Update apt packages every 15 minutes, preventing sleep:

```bash
./run_in_intervals.sh --interval=15 --no-sleep "apt update && apt upgrade -y"
```


## Log File

The script logs all command outputs and execution times to `run_in_intervals.log` in the same directory.

## Notes

- The script runs continuously until manually stopped
- For Linux systems, it will attempt to install `caffeine` if not present
- Ensure the script has execute permissions: `chmod +x run_in_intervals.sh`
- The `--no-sleep` option requires `caffeinate` on macOS or `caffeine` on Linux.