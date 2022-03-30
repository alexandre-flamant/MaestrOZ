declare
fun {Drone PartitionItem N}
      %
      % Repeat a Note multiple times
      % Args:
      %    Node (ExtendedNote|ExtendedChord)  
      %        Note to which the transformation is applied on.
      %    N (Int) 
      %        Number of times the note needs to be repeated.
      % Return:
      %    Resulting partition
      %   
      
   if N=<0 then nil
   else PartitionItem|{Drone PartitionItem N-1}
   end
end

Note = note(name:a octave:1 sharp:false duration:1.0 instrument:violon)
Chord = chord(note(name:c octave:3 sharp:false duration:3.0 instrument:violon)
	      note(name:d octave:3 sharp:false duration:3.0 instrument:violon)
	      note(name:e octave:3 sharp:false duration:3.0 instrument:violon))

{Browse {Drone Chord 3}}
{Browse {Drone Note 5}}