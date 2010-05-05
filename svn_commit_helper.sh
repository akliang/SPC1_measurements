#!/bin/bash

# this script replaces %%{ with %{ in meas_description.m,
# effectively activating all block comments.
# it also creates a backup file before doing so

mv meas_description.m meas_description_backup.m
cat meas_description_backup.m | sed -r -e 's/^%%\{$/%\{/' >meas_description.m

echo "Suggested commands to execute now:
svn commit meas_description.m -m 'place comment here'
mv meas_description_backup.m meas_description.m
"
