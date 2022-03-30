declare
fun {Stretch F Partition}
      %
      % Set the duration of a partition
      % Args:
      %    T (Float) 
      %        New duration of the partition in seconds.
      %    Partition (List)  
      %        Partition to which the transformation is applied on.
      % Return:
      %    Transformed partition
      %   
      fun {Transform PartitionItem}
	 case {Label PartitionItem}
	 of note then 
	    {Record.adjoinAt PartitionItem duration (PartitionItem.duration * F)}
	 [] silence then 
	    {Record.adjoinAt PartitionItem duration (PartitionItem.duration * F)}
	 [] chord then
	    {Record.map PartitionItem fun{$ Note} {Record.adjoinAt Note duration (Note.duration * F)} end}
	 else
	    raise 'Stretch transformation error' end
	 end
      end
in
   {Map Partition Transform} % Scaling partition by the right amount
end

Partition = [note(name:a octave:1 sharp:false duration:1.0 instrument:violon)
	     note(name:b octave:2 sharp:false duration:2.0 instrument:violon)
	     chord(note(name:c octave:3 sharp:false duration:3.0 instrument:violon)
		   note(name:d octave:3 sharp:false duration:3.0 instrument:violon)
		   note(name:e octave:3 sharp:false duration:3.0 instrument:violon))
	     note(name:d octave:4 sharp:false duration:4.0 instrument:violon)
	     note(name:e octave:5 sharp:false duration:5.0 instrument:violon)]

{Browse Partition}
{Browse {Stretch 0.5 Partition}}