#!/bin/bash

# Default values
INTERVAL_MINUTES=30
USE_CAFFEINATE=false
COMMAND=""
LOG_FILE="run_in_intervals.log"

usage() {
    echo "Usage: $0 [--interval=MINUTES] [--no-sleep] COMMAND"
    echo "  --interval=MINUTES  Set the interval between command executions (default: 30)"
    echo "  --no-sleep          Prevent system sleep during command execution"
    echo "  COMMAND             The command to run at specified intervals"
    exit 1
}

check_caffeinate() {
    if ! command -v caffeinate &> /dev/null; then
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            echo "caffeinate is not available on Linux. Installing 'caffeine' as an alternative..."
            if command -v apt-get &> /dev/null; then
                sudo apt-get update && sudo apt-get install -y caffeine
            elif command -v dnf &> /dev/null; then
                sudo dnf install -y caffeine
            elif command -v yum &> /dev/null; then
                sudo yum install -y caffeine
            else
                echo "Error: Unable to install caffeine. Please install it manually."
                echo "The --no-sleep option will be ignored."
                USE_CAFFEINATE=false
            fi
        else
            echo "Warning: caffeinate or equivalent is not available on this system. The --no-sleep option will be ignored."
            USE_CAFFEINATE=false
        fi
    fi
}

run_command() {
    if $USE_CAFFEINATE; then
        if [[ "$OSTYPE" == "darwin"* ]] || [[ "$OSTYPE" == "linux-gnu"* ]]; then
            caffeinate $COMMAND 2>&1 | tee -a "$LOG_FILE"
        else
            eval "$COMMAND" 2>&1 | tee -a "$LOG_FILE"
        fi
    else
        eval "$COMMAND" 2>&1 | tee -a "$LOG_FILE"
    fi
}

run_job() {
    local job_interval=$1
    while true; do
        echo "$(date): Running command" | tee -a "$LOG_FILE"
        run_command 2>&1 | tee -a "$LOG_FILE" &
        echo "$(date): Command started in background. Sleeping for $job_interval minutes" | tee -a "$LOG_FILE"
        sleep $((job_interval * 60))
    done
}

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --interval=*)
                INTERVAL_MINUTES="${1#*=}"
                if ! [[ "$INTERVAL_MINUTES" =~ ^[0-9]+$ ]]; then
                    echo "Error: Invalid interval. Please provide a positive integer."
                    usage
                fi
                shift
                ;;
            --no-sleep)
                USE_CAFFEINATE=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            *)
                if [ -z "$COMMAND" ]; then
                    COMMAND="$1"
                else
                    COMMAND="$COMMAND $1"
                fi
                shift
                ;;
        esac
    done

    # Validate that a command was provided
    if [ -z "$COMMAND" ]; then
        echo "Error: No command provided."
        usage
    fi
}

main() {
    parse_arguments "$@"

    # Check for caffeinate if USE_CAFFEINATE is true
    if $USE_CAFFEINATE; then
        check_caffeinate
    fi

    run_job "$INTERVAL_MINUTES"
}

main "$@"
