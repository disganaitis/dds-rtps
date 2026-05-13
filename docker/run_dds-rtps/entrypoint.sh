#!/bin/bash

cd dds-rtps
. .venv/bin/activate
git pull
git checkout add_new_test_python_0725
echo "Running pub:" $1
echo "Running sub:" $2
python3 interoperability_report.py -P /opt/executables/$1 -S /opt/executables/$2 -v
cp *.xml /opt/outputs
