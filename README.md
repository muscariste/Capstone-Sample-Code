# Capstone-Sample-Code
This repository contains some sample code from my EECE Capstone Project. For a detailed description of the project, see the final report included in the repository.

plot_room_attenuation.m is a script that plots the attenuation pattern of a 2D slice of a two array beamforming mic array system with arrays on the right and left side of a room.

plot_room_d_lam.m plots multiple room attenuation patterns for different values of d / lambda which determines the beam width, where d is microphone spacing and lambda is the signal wavelength.

plot_symmetric_array_attenuation.m plots the attenuation pattern of a single symmetric microphone array placed at the front of a room.

The folder simulink_creation contains makeDelayMux.m, a helpful script for automatically generating Simulink blocks used in the final simulink code for the completed prototype. See test.m for example usage.

The folder simulink_files contains the Simulink files for a few different iterations of our device.

Lastly, room_sweep.gif is a nice image showing the attenuation pattern for our simulated system sweeping through a room.
