declare
fun {Transpose N Partition}
         %
         % Shift the partition by a number of semitone
         % Args:
         %    N (Int) 
         %        Number of demitone to shift the partition by.
         %    Partition (List)  
         %        Partition to which the transformation is applied on.
         % Return:
         %    Transformed partition
         %  
      
   NamesToNum = name(c:0 d:2 e:4 f:5 g:7 a:9 b:11)
   SharpToNum = sharp(false:0 true:1)
   
   NumToName  = num(0:c 1:c 2:d 3:d 4:e 5:f 6:f 7:g 8:g 9:a 10:a 11:b)
   NumToSharp = num(0:false 1:true 2:false 3:true 4:false 5:false 6:true 7:false 8:true 9:false 10:true 11:false)
   
   
   fun {Shift Note}
      I NewName NewSharp NewOctave
   in
      I = NamesToNum.(Note.name) + SharpToNum.(Note.sharp) + 12 * Note.octave
      NewName = NumToName.({Number.abs (I+N) mod 12})
      NewSharp = NumToSharp.({Number.abs (I+N) mod 12})
      NewOctave = (I+N) div 12
      {Record.adjoinAt {Record.adjoinAt {Record.adjoinAt Note name NewName} sharp NewSharp} octave NewOctave}
   end
   
   fun {Transform PartitionItem}
      case {Label PartitionItem}
      of note then 
	 {Shift PartitionItem}
      [] silence then 
	 raise "Silence can not be transposed !" end
      [] '|' then
	 {List.map PartitionItem Shift}
      else
	 raise 'Transpose transformation error' end
      end
   end
in
   {Map Partition Transform}
end

Partition = [note(name:a octave:1 sharp:false duration:1.0 instrument:violon)
	     note(name:b octave:1 sharp:false duration:2.0 instrument:violon)
	     [note(name:c octave:1 sharp:false duration:3.0 instrument:violon)
	      note(name:d octave:1 sharp:false duration:3.0 instrument:violon)
	      note(name:e octave:1 sharp:false duration:3.0 instrument:violon)]
	     note(name:f octave:1 sharp:false duration:4.0 instrument:violon)
	     note(name:g octave:1 sharp:false duration:5.0 instrument:violon)]

{Browse Partition}
{Browse {Transpose 13 Partition}}