#!/bin/bash

# this script replaces %%{ with %{ in meas_description.m,
# and writes its output to meas_description_svn.m
# (which is the actual file under version control)

echo "Creating block-commented version of meas_description.m as meas_description_svn.m..."
cat meas_description.m | sed -r -e 's/^%%\{$/%\{/' >meas_description_svn.m

echo "Suggested commands to execute now:
svn commit meas_description_svn.m -m 'place comment here'
"
