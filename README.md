# Anthropogenic-signal-evaluation-for-PRS
Welcome to the Anthropogenic-signal-evaluation-for-PRS wiki!

Relevant autocorrlations are in projects. 

This repository will showcase autocorrelations for direct and reflected path anthropogenic signals as they travel to and through a glacier from nearby illuminators of opportunity. 
The autocorrelation plots will be of LTE, DVB-T, DAB, and GSM signals. 

The simulations assume a direct path beam and a reflected path beam that travels through a glacier and bounces off the bedrock before it hits a receiver sitting atop the glacier. 
The autocorrelation plots show the expected delay time between when the direct path and reflected path hits the receiver. 
This delay time should correspond to the second largest peak in the autocorrelation of these two signals. 
The first peak at zero seconds represent the direct path signal, other peaks are sidelobes of both the direct path and reflected path signal.

The code included is a model that can be applied to any location/glacier on earth with an illuminator of opportunity nearby. Inputting the signal characteristics of the IOO, the local geometry and the specs of your receiver you plan to use, this model can determine either the range you need to be at for an echo to be detected in an autocorrelation or up to what depth you are able to detect an echo. 
