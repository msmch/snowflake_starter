#! /bin/bash
# Create virtual env for the project if it doesn't exist already
# Python 3.12

if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python -m venv .venv
fi

echo "Activating virtual environment..."
source .venv/Scripts/activate

echo "Installing dependencies..."
python -m pip install --upgrade pip
pip install -r requirements.txt
pip install automation_scripts/date_type_detector/date_type_detector-0.1.0-cp312-cp312-win_amd64.whl

echo "Setup complete!"