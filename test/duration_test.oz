declare
fun {Duration T Partition}
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
   InitT = {List.foldR Partition fun {$ PartitionItem T}
				    case {Label PartitionItem}
				    of note then T + PartitionItem.duration
				    [] '|' then T + PartitionItem.1.duration
				    end
				 end
	    0.0} % Initial partition duration
   
      fun {Transform PartitionItem}
	 case {Label PartitionItem}
	 of note then 
	    {Record.adjoinAt PartitionItem duration (PartitionItem.duration * T/InitT)}
	 [] silence then 
	    {Record.adjoinAt PartitionItem duration (PartitionItem.duration * T/InitT)}
	 [] '|' then
	    {List.map PartitionItem fun{$ Note} {Record.adjoinAt Note duration (Note.duration * T/InitT)} end}
	 else
	    {Show 'Duration transformation'}
	    {Show 'PartitionItem:'}
	    {Show PartitionItem}
	    nil
	 end
      end
in
   {Browse InitT}
      {Map Partition Transform} % Scaling partition by the right amount
end

Partition = [note(name:a octave:1 sharp:false duration:1.0 instrument:violon)
	     note(name:b octave:2 sharp:false duration:2.0 instrument:violon)
	     [note(name:c octave:3 sharp:false duration:3.0 instrument:violon)
	      note(name:d octave:3 sharp:false duration:3.0 instrument:violon)
	      note(name:e octave:3 sharp:false duration:3.0 instrument:violon)]
	     note(name:d octave:4 sharp:false duration:4.0 instrument:violon)
	     note(name:e octave:5 sharp:false duration:5.0 instrument:violon)]

{Browse Partition}
{Browse {Duration 30.0 Partition}}
