% Flamant Alexandre 5308 1500
local
   % See project statement for API details.
   [Project] = {Link ['Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                           Data Type Conversion                            %
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

   fun {ChordToExtended Chord}
      {Map Chord NoteToExtended}
   end

   fun {ToExtended Item}
      case Item
      of H|T then {ChordToExtended Item}
      else {NoteToExtended Item}
      end
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                           Transformations                                 %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
      
      % Tranformation to map to the partition
      fun {Transform PartitionItem}
         case {Label PartitionItem}
         of note then % If it is a node we just change its duration
            {Record.adjoinAt PartitionItem duration (PartitionItem.duration * T/InitT)}
         [] silence then % If it is a silence we just change its duration
            {Record.adjoinAt PartitionItem duration (PartitionItem.duration * T/InitT)}
         [] '|' then % If it is a chord we change the duration of all notes by mapping
            {List.map PartitionItem fun{$ Note} {Record.adjoinAt Note duration (Note.duration * T/InitT)} end}
         else
            raise 'Duration transformation error' end
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

      % Tranformation to map to the partition
      fun {Transform PartitionItem}
         case {Label PartitionItem}
         of note then % If it is a node we just change its duration
            {Record.adjoinAt PartitionItem duration (PartitionItem.duration * F)}
         [] silence then % If it is a silence we just change its duration
            {Record.adjoinAt PartitionItem duration (PartitionItem.duration * F)}
         [] '|' then % If it is a chord we change the duration of all notes by mapping
            {List.map PartitionItem fun{$ Note} {Record.adjoinAt Note duration (Note.duration * F)} end}
         else
            raise 'Stretch transformation error' end
         end
      end
   in
      {Map Partition Transform} % Scaling partition by the right amount
   end


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
   
      % Table for note to integer conversion
      NamesToNum = name(c:0 d:2 e:4 f:5 g:7 a:9 b:11)
      SharpToNum = sharp(false:0 true:1)
      
      % Table for integer to note conversion
      NumToName  = num(0:c 1:c 2:d 3:d 4:e 5:f 6:f 7:g 8:g 9:a 10:a 11:b)
      NumToSharp = num(0:false 1:true 2:false 3:true 4:false 5:false 6:true 7:false 8:true 9:false 10:true 11:false)

      % Function to transpose a note
      fun {Shift Note}
         I NewName NewSharp NewOctave
      in
         I = NamesToNum.(Note.name) + SharpToNum.(Note.sharp) + 12 * Note.octave
         NewName = NumToName.({Number.abs (I+N) mod 12})
         NewSharp = NumToSharp.({Number.abs (I+N) mod 12})
         NewOctave = (I+N) div 12
         {Record.adjoinAt {Record.adjoinAt {Record.adjoinAt Note name NewName} sharp NewSharp} octave NewOctave}
      end

      % Function to map to the partition
      fun {Transform PartitionItem}
         case {Label PartitionItem}
         of note then % If it is a note we transpose the note
            {Shift PartitionItem}
         [] silence then  % If it is a silence we do nothing
            PartitionItem
         [] '|' then % If it is a chord we shift all notes (there should not be any silence in chords)
            {List.map PartitionItem Shift}
         else
            raise 'Transpose transformation error' end
         end
      end
   in
      {Map Partition Transform}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                            Partition Creation                             %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}    
      fun {Transform PartitionItem}
         case PartitionItem
         of H|T then {Map PartitionItem NoteToExtended}
         [] duration(seconds:T Partition) then
      {Duration T {Map Partition ToExtended}}
         [] stretch(factor:F Partition) then
      {Stretch F {Map Partition ToExtended}}
         [] drone(note:Note amount:N) then
      {Drone {ToExtended Note} N}
         [] transpose(semitones:N Partition) then
      {Transpose N {Map ToExtended Partition}}
         [] Atom then {NoteToExtended PartitionItem}
         else
      {Show 'Main function'}
      {Show 'PartitionItem:'}
      {Show PartitionItem}
      nil
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