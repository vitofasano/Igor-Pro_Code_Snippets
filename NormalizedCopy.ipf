#pragma rtGlobals=1		// Use modern global access method.
// 
// An improved normalization function for spectroscopic application.
// Igor Pro user function for the normalization of spectra with baseline correction and smoothing options.
// version 0.1 
// Vito Fasano - 2016/03/24 - vito.fasano@gmail.com
//
//    An improved normalization function for spectroscopic application.
//    Copyright (C) 2016  Vito Fasano
//
//   This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    any later version.
//
//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.
//
//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.
//
// It has been tested with Igor Pro 6.22A, but it may work with other versions. 
//
// Credits: Parts of the procedure is based on:
// http://payam.minoofar.com/wp-content/uploads/2007/07/introduction_to_igor_programming.pdf
// Special thanks to Payam Minoofar - http://payam.minoofar.com/

// Mini-guide of input of NormalizedCopy function:
// > input : spectrum wave to normalize
// > peakvalue : peak values of normalized spectum, i.e. peakvalue = 1
// > modality : 0 for simple modality (without specific peak range detection or  baseline correction) or,
// > modality : 1 for improved modality (with specific peak range detection or  baseline correction)
// > rangetype : 1 for peak and baseline values detection over the specified range of POINTS ( denoted by brackets: [leftmark,rightmark] ) or,
// > rangetype : 2 for peak and baseline values detection over the specified range of X RANGE ( denoted by parentheses: (leftmark,rightmark) ) 
// > leftmark, rightmark : marks of peak range (POINTS or X RANGE)
// > bc_switch : 0 for no-baseline correction or 1 for baseline correction
// > left_bc, right_bc : marks of baseline range (POINTS or X RANGE)
// > smth: 0 for no-smoothing on normalized spectrum or 1 for smoothing on normalized spectrum
// > smth_points : Parameter for smoothing function
// > nametype : 0 for "_norm" suffix for normalized wave name or 1 for "norm_" prefix for normalized wave name
//
// There are different modes to use this procedure:
// - simple modality: modality input=0 
//   (the rangetype, leftmark, rightmark, bc_switch, left_bc, right_bc input are ignored, but they must be declared)
// - improved modality: modality input=1 
//   (specific peak range detection or  baseline correction are enable)
// In improved modality:
// > in order to switch-off the specific peak range detection the leftmark and rightmark input must be equal
// > in order to switch-off the baseline correction bc_switch input must be zero.
// The smoothing option for normalized spectrum can be used in both modalities (simple or improved modality)
//

Function NormalizedCopy(input, peakvalue, modality, rangetype, leftmark, rightmark, bc_switch, left_bc, right_bc, smth, smth_points, nametype)
Wave input
Variable peakvalue, modality, rangetype, leftmark, rightmark, bc_switch, left_bc, right_bc, smth, smth_points, nametype
Variable maxValue,Bottom
Bottom=0

// Make sure that the input for modality is valid.
// Otherwise, exit function.
if (modality<0 || modality>1)
print "ATTENTION: modality input is not valid!"
return -1
endif
// Make sure that the input for rangetype is valid.
// Otherwise, exit function.
if (rangetype<1 || rangetype>2)
print "ATTENTION: rangetype input is not valid!"
return -1
endif
// Make sure that the input for bc_switch (baseline_switch) is valid.
// Otherwise, exit function.
if (bc_switch<0 || bc_switch>1)
print "ATTENTION: bc_switch (baseline_switch) input is not valid!"
return -1
endif
// Make sure that the input for left_bc is minor to input for right_bc.
// Otherwise, exit function.
if (bc_switch == 1)
if (left_bc > right_bc)
print "Warning: left_bc is major to right_bc, however the normalization function will work properly."
endif
endif
// Make sure that the input for smth is valid.
// Otherwise, exit function.
if (smth<0 || smth>1)
print "ATTENTION: smth input is not valid!"
return -1
endif
// Make sure that the input for smth_points is valid.
// Otherwise, exit function.
if (smth_points<1)
print "ATTENTION: smth_points input is not valid!"
return -1
endif
// Make sure that the input for nametype is valid.
// Otherwise, exit function.
if (nametype<0 || nametype>1)
print "ATTENTION: nametype input is not valid!"
return -1
endif
// Make sure that the input for leftmark is different to input for rightmark.
// Otherwise, exit function.
if (leftmark == rightmark)
print "Warning: leftmark is equal to rightmark, then the peak detection will be disabled."
endif
// Make sure that the input for leftmark is minor to input for rightmark.
// Otherwise, exit function.
if (leftmark > rightmark)
print "Warning: leftmark is major to rightmark, however the normalization function will work properly."
endif

// "norm" will be added to name of original wave ( before or after ) 
// to make name of normalized wave
if (nametype==0)			//suffix
String outputName = NameofWave(input)+"_norm"
endif
if (nametype==1)	
outputName = "norm_" + NameofWave(input)
endif
// Duplicate the original wave as a wave with the new name, and optionally smoothed
if (smth==0)
Duplicate /O input $outputName
Wave output = $outputName
else
Duplicate /O input $outputName
Wave output = $outputName
// Default smoothing algorithm: BOX
Smooth/B smth_points, output
// Other smoothing algorithm: BINOMIAL
// Smooth smth_points, output
endif

// If modality is 0, then normalize to absolute max without baseline correction.
if (modality==0)
WaveStats/Q output
maxValue = V_max
endif
// If modality is 1 and if rangetype is 1, then
// normalize to peak over the specified range of POINTS ( denoted by brackets: [leftmark,rightmark] ) and
// make baseline correction over the other specified range of POINTS ( denoted by brackets: [left_bc,right_bc] ) 
if (modality==1)
if (rangetype==1)
if (leftmark != rightmark)
WaveStats/Q/R=[leftmark,rightmark] output
else
WaveStats/Q output
print "The peak detection is disabled, then the spectrum is normalized to its absolute max."
endif
maxValue = V_max
if (bc_switch==1)
WaveStats/Q/R=[left_bc,right_bc] output
Bottom=V_avg
endif
endif
endif
// If modality is 1 and if rangetype is 2, then 
// normalize to peak over the specified range X RANGE ( denoted by parentheses: (leftmark,rightmark) ) and
// make baseline correction over the other specified range X RANGE ( denoted by parentheses: (left_bc,right_bc) ) 
if (modality==1)
if (rangetype==2)
if (leftmark != rightmark)
WaveStats/Q/R=(leftmark,rightmark) output
else
WaveStats/Q output
print "The peak detection is disabled, then the spectrum is normalized to its absolute max."
endif
maxValue = V_max
if (bc_switch==1)
WaveStats/Q/R=(left_bc,right_bc) output
Bottom=V_avg
endif
endif
endif

// Normalize and baseline correct the wave to specified peak
output = ( (output - Bottom ) / (maxValue - Bottom) ) * peakvalue

// Results
if (modality==1)
if (bc_switch==1)
print "Baseline value of original spectum is", Bottom, "-- Baseline value of normalized spectum is", (Bottom-Bottom)/maxValue*peakvalue
endif
endif
print "MaxValue of original spectum is", MaxValue, "-- MaxValue of normalized spectum is", peakvalue
print "Normalization function works well!!"
print "The normalized spectrum wave is created and it is named <"$outputName,">."
return 0
End