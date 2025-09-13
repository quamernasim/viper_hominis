#!/bin/bash

# Build GLIP if not already built
function build_glip() {
    source /opt/conda/bin/activate viperhominis

    cd /app/GLIP
    python setup.py clean --all build develop --user
    cd /app
}

# Setup function to prepare the container environment
function setup() {
    if [ ! -f /app/GLIP/.built ]; then
        touch /app/GLIP/.built
        build_glip
    fi
}

# Initialize and run setup
setup

# Execute the passed command
if [[ $# -eq 0 ]]; then
    echo "Starting FastAPI server..."
    # Activate the conda environment and start the FastAPI server
    /opt/conda/bin/conda run -n viperhominis uvicorn app:app --host 0.0.0.0 --port 8000
else
    echo "Running command: "
    exec "$@"
fi
