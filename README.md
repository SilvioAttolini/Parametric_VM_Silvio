# Parametric_VM_Silvio

## Noise and SC
+ Habets assumes an isotropic distribution of the NF, continuous 
  and coherent over time
  + diffuse input chosen (and scaled) randomly among the diffuse part of 
    the mic arrays. (consider applying a phase shift also here maybe)
  + diffuse at the interested vm using
    a weighted average of the amplitudes with delayed phases to 
    avoid artifacts 
+ We may add the noise directly to the source signal before casting 
  it into the room, so that the starting noise gets propagated 
  along with the signal

## Future improvements
+ RIR calculation (propose new_rir)
+ Source localization
+ De-reverberation
+ Spherical harmonics expansion coefficients estimation
+ Direct signal estimation using Sph Coeffs

