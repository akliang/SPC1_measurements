# SPC1 measurement scripts

This collection of scripts is used to control various measurement instruments used to characterize the performance of the SPC1 photon counting image sensor ASICs.  The scripts take control of source meter units (SMUs) to set bias voltages, program signal generators to created input pulses with the right shape, amplitude and frequency, and operate an oscilloscope in order to sample the output signals picked up by the low-capacitance probes.

## Important scripts

SMU control:
* SPCsetup1 - a configuration file to specify the IP address and channel names of the SMUs
* multim_2636A_unified.sh - the control script that sends commands to the SMU to change voltages via a command line interface

Measurement input and output:
* SPC/meas_characterize_general.py - a master control script that sets parameters for the oscilloscope that are common to all measurement types, also creates the measurement directory
* SPC/meas_characterize_amp.py - sets the signal generator to create a triangle wave and steps through all the bias voltages
* SPC/meas_characterize_comp.py - creates a triangle wave to determine the optimal setting for the comparator
* SPC/meas_characterize_countrate.py - creates square waves used to determine count rate (used for the comparator, clock generator and counter)

Analysis:
* SPC/analysis/analyze_*_meas.m - automatically takes the directory path of the raw measurements, parses the dirty oscilloscope data into clean CSV files, ingests it, smooths out noise, and extract metrics
* make_paper_plots*.m - after the data has been processed, this script takes the output .mat files and generates paper-quality pretty plots

