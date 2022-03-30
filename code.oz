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

         initT = {Record.foldR Partition fun {$ Note T} T + Node.duration end 0} % Initial partition duration
      in
         {Map Partition fun{$ Note} {Record.adjoinAt Note duration (Note.duration * T/initT)} end} % Scaling partition by the right amount
      end
      

      fun {stretch F Partition}
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
      
         {Map Partition fun{$ Note} {Record.adjoinAt Note duration (Note.duration * F)} end} % Scaling partition by F
      end
      

      fun {Drone N Note}
      %
      % Repeat a Note multiple times
      % Args:
      %    N (Int) 
      %        Number of times the note needs to be repeated.
      %    Node (List)  
      %        Note to which the transformation is applied on..
      % Return:
      %    Resulting partition
      %   
      
         if N<=0 then nil
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
         Notes = [note(name:c sharp:false) note(name:c sharp:true) note(name:d sharp:false)
                  note(name:d sharp:true) note(name:e sharp:false) note(name:f sharp:false)
                  note(name:f sharp:true) note(name:g sharp:false) note(name:g sharp:true)
                  note(name:a sharp:false) note(name:a sharp:true) note(name:b sharp:false)]

         fun {Index Note} 
            fun {Aux Note L I}
               case L
               of nil then
                   raise 'Could not find thz note' end
               [] H|T then
                  if {And (Note.name == H.name) (Note.sharp == H.sharp)} then I
                  else {Aux Note T (I+1)}
                  end
               end
            end
         in
            {Aux Note Notes 0}
         end

         fun {Shift Note}
            I NewNote NewName NewSharp NewOctave
         in
            I = {Index Note}
            NewNote = {List.nth Notes (I+N) mod 12}
            NewName = NewNote.name
            NewSharp = NewNote.sharp
            NewOctave = (I+N) div 12
            {Record.adjoinAt {Record.adjoinAt {Record.adjoinAt Note name NewName} sharp NewSharp} octave NewOctave}
         end
      in
         {Aux N Partition}
      end
   
   in 
      {Map Partition Shift}
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