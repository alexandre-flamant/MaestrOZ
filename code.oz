local
   % See project statement for API details.
   [Project] = {Link ['Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   % Translate a note to the extended notation.
   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
         case {AtomToString Atom}
         of [_] then
            note(name:Atom octave:4 sharp:false duration:1.0 instrument:none)
         [] [N O] then
            note(name:{StringToAtom [N]}
                 octave:{StringToInt [O]}
                 sharp:false
                 duration:1.0
                 instrument: none)
         end
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}

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
         initT = {Record.foldR Partition fun {$ Note T} T + Note.duration end 0} % Initial partition duration
         fun {Transform PartitionItem}
            case {Label PartitionItem}
            of note then 
               {Record.adjoinAt PartitionItem duration (PartitionItem.duration * T/initT)}
            [] silence then 
               {Record.adjoinAt PartitionItem duration (PartitionItem.duration * T/initT)}
            [] chord then
               {Map PartitionItem fun{$ Note} {Record.adjoinAt Note duration (Note.duration * T/initT)} end}
            end
         end
      in
         {Map Partition Transform} % Scaling partition by the right amount
      end
   
      fun {Stretch F Partition}
      %
      % Stetch the partition by a desired factor
      % Args:
      %    F (Float) 
      %        Stretch factor for the transformation. F<1 leads to a shorter partition while F>1 leads to a longer partition.
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
            {Map PartitionItem fun{$ Note} {Record.adjoinAt Note duration (Note.duration * F)} end}
         end
         end
      in
         {Map Partition Transform} % Scaling partition by the right amount
      end
   
      
      fun {Drone N Note}
      %
      % Repeat a Note multiple times
      % Args:
      %    N (Int) 
      %        Number of times the note needs to be repeated.
      %    Node (ExtendedNote|ExtendedChord)  
      %        Note to which the transformation is applied on..
      % Return:
      %    Resulting partition
      %   
   
         if N=<0 then nil
         else Note|{Drone (N-1) Note}
         end
      end
      
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
         
         NumToName  = num(0:c 1:c 2:d 3:d 4:e 5:f 6:f 7:g 8:g 9:a 10:a 11:a)
         NumToSharp = num(0:false 1:true 2:false 3:true 4:false 5:false 6:true 7:false 8:true 9:false 10:true 11:false)
         
         
         fun {Shift Note}
            I NewName NewSharp NewOctave
         in
            I = NamesToNum.(Note.name) + SharpToNum.(Note.sharp)
            NewName = NumToName.((I+N) mod 12)
            NewSharp = NumToSharp.((I+N) mod 12)
            NewOctave = (I+N) div 12
            {Record.adjoinAt {Record.adjoinAt {Record.adjoinAt Note name NewName} sharp NewSharp} octave NewOctave}
         end
         
         fun {Transform PartitionItem}
            case {Label PartitionItem}
            of note then 
               {Shift PartitionItem}
            [] silence then 
               raise "Silence can not be transposed !" end
            [] chord then
               {Map PartitionItem Shift}
            end
         end
      in
         {Map Partition Transform}
      end
      
   in 
      skip
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
      % TODO
      {Project.readFile 'wave/animals/cow.wav'}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Music] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
end