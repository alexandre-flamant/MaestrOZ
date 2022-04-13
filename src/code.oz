% Flamant Alexandre 5308 1500
% View full source on gitfront
% https://gitfront.io/r/Alexandre-Flamant/AQtgGMzRi21n/MaestrOZ/

local
   % See project statement for API details.
   [Project] = {Link ['src/Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                             Control variables                             %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   Pi = 3.14159265359
   SamplingSize = 44100.0
   Smoothing = true

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                           Data Type Conversion                            %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {NoteToExtended Note}
   %
   % Convert a Note to its extended version.
   % That is a record with the following structure:
   % note(name octabe sharp duration instrument)
   % silence(duration)
   % 
   % Arg:
   %    Note
   %        Note to extend
   %
   % Return:
   %    Extended Note
   %
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      % This case was added for identity purpose.
      % That is if the input is already extended nothing is done
      [] silence(duration:_) then
         Note
      % This case was added for identity purposes.
      % That is if the input is already extended nothing is done
      [] note(name:_ octave:_ sharp:_ duration:_ instrument:_) then
         Note
      [] silence then silence(duration:1.0)
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
         else
            {Show Note}
            raise 'Incorrect note' end
         end
      else
         {Show Note}
         raise 'Incorrect note' end
      end
   end

   fun {ChordToExtended Chord}
   %
   % Convert a Chord to its extended version.
   % That is a list containing extended notes
   % Args:
   %    Chord (List)
   %        List of notes
   %
   % Return;
   %    Extended chord
   %
      {Map Chord NoteToExtended}
   end
   
   fun {ToExtended Item}
   %
   % Convert a note or chord to its extended version.
   % Arg:
   %    Item
   %        Note or chord to convert
   %
   % Return
   %    Return a record representing the extended note or extended chord
   %

      if {List.is Item} then {ChordToExtended Item}
      elseif Item == silence then silence(duration:1.0)
      else {NoteToExtended Item}
      end   
   end   

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                           Transformations                                 %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Duration T Partition}
   %
   % Set the duration of a partition
   %
   % Args:
   %    T (Float) 
   %        New duration of the partition in seconds
   %    Partition (List)  
   %        Partition to which the transformation is applied on
   %
   % Return:
   %    Transformed partition
   %   

      InitT = {List.foldR Partition fun {$ PartitionItem T}
                                       case {Label PartitionItem}
                                       of note then T + PartitionItem.duration
                                       [] silence then T + PartitionItem.duration
                                       [] '|' then T + PartitionItem.1.duration
                                       [] nil then 0.0
                                       else
                                          {Show PartitionItem}
                                          raise 'Incorrect item in Duration' end
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
         [] nil then nil
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
   %
   % Args:
   %    F (Float) 
   %        Stretch factor for the transformation. F<1 leads to a shorter partition while F>1 leads to a longer partition
   %    Partition (List)  
   %        Partition to which the transformation is applied on
   %
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
   %
   % Args:
   %    Node (ExtendedNote|ExtendedChord)  
   %        Note to which the transformation is applied on
   %    N (Int) 
   %        Number of times the note needs to be repeated
   %
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
   %
   % Args:
   %    N (Int) 
   %        Number of demitone to shift the partition by
   %    Partition (List)  
   %        Partition to which the transformation is applied on
   %
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
   %
   % Generate a timed partition consisting of extended notes and chords
   % based on a partition.
   %
   % Args:
   %    Partition (List(PartitionItem)) 
   %        list of partition items
   %
   % Return:
   %      Timed partition as a list of extended notes and chords
   %  

      ReversedPartition = {List.reverse Partition}

      fun {Aux Partition Acc}
         case Partition
         of PartitionItem|T then
            case PartitionItem
            of duration(seconds:Time P) then
               {Aux T {List.append {Duration Time {PartitionToTimedList P}} Acc}}
            [] stretch(factor:F P) then
               {Aux T {List.append {Stretch F {PartitionToTimedList P}} Acc}}
            [] drone(note:Note amount:N) then
               {Aux T {List.append {Drone {ToExtended Note} N} Acc}}
            [] transpose(semitones:N P) then
               {Aux T {List.append {Transpose N {PartitionToTimedList P}} Acc}}
            else
               {Aux T {ToExtended PartitionItem}|Acc}
            end
         [] nil then Acc   
         else {Show Partition} raise 'Wrong partition item' end
         end
      end
   in
      {Aux ReversedPartition nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                             Sound generation                              %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Pitch Note}
   %
   % Compute the pitch of a Note. That is the number of semitones between that
   % note and A4.
   %
   % Args:
   %    Note (ExtendedNote) 
   %       Note to compute the pitch of
   %
   % Return: (Integer)
   %    Pitch of the note 
   %  
      % Table for note to integer conversion
      NamesToNum = name(c:0 d:2 e:4 f:5 g:7 a:9 b:11)
      SharpToNum = sharp(false:0 true:1)

      A4Pitch = 4*12 + 9 + 0 % 57
      NotePitch
   in
      NotePitch = Note.octave * 12 + NamesToNum.(Note.name) + SharpToNum.(Note.sharp)
      NotePitch - A4Pitch
   end
   

   fun {Frequency Note}
   %
   % Compute the frequency of a note based on its Note.
   %
   % Args:
   %    Note (ExtendedNote)
   %        Note to compute the frequency of
   %
   % Return: (Float)
   %    Frequency of the note
   %  
      NotePitch = {Int.toFloat {Pitch Note}}
   in
      {Number.pow 2.0 (NotePitch/12.0)} * 440.0
   end


   fun {NoteSample Note}
   %
   % Compute the sample of a note based on its Note.
   % Values ai are bounded to the interval [-1.0 1.0]
   %
   % Args:
   %    Note (ExtendedNote)
   %        Note to compute the  sample of
   %
   % Return: (List(Float))
   %    Sample of the note
   %  
      Sample = {List.make {Float.toInt {Float.round SamplingSize * Note.duration}}}
      NoteFrequency = {Frequency Note}
   in
      {List.forAllInd Sample proc{$ I Ai} Ai = 0.5 * {Float.sin (2.0 * Pi * NoteFrequency * {Int.toFloat I-1}/SamplingSize)} end}
      
      if Smoothing then
         local
            DT = {Min 0.015 0.2 * Note.duration}
         in
            {Fade DT DT Sample}
         end
      else
         Sample
      end
   end
   

   fun {SilenceSample Silence}
   %
   % Compute the sample of a Silence.
   % Values ai of a silence is always equal to 0.0
   %
   % Args:
   %    Silence (ExtendedNote)
   %        Silence to compute the sample of
   %
   % Return: (List(Float))
   %    Sample of the Silence
   %  
      Sample = {List.make {Float.toInt {Float.round SamplingSize * Silence.duration}}}
   in
      {List.forAll Sample proc{$ Ai} Ai = 0.0 end}
      Sample
   end

   fun {ChordSample Chord}
   %
   % Compute the sample of a Chord.
   % Values ai of a chord is bounded to the interval [-1.0 1.0].
   % These coefficient are calculated as the mean of the intensity
   % of all notes played by the chord.
   %
   % Args:
   %    Silence (ExtendedNote)
   %        Silence to compute the sample of
   %
   % Return: (List(Float))
   %    Sample of the Silence
   % 

      Sample = {List.make {Float.toInt {Float.round SamplingSize * Chord.1.duration}}}
      Pi = 3.14159265359
      L = {Int.toFloat {List.length Chord}}

      proc {Aux I Ai}
         fun {AuxNested Note} 
            NoteFrequency = {Frequency Note}
         in
            0.5 * {Float.sin (2.0 * Pi * NoteFrequency * {Int.toFloat I}/SamplingSize)}
         end
      in
         Ai = {List.foldR {Map Chord AuxNested} fun {$ X Y} X + Y end 0.0}/L
      end

   in
      {List.forAllInd Sample Aux}
      Sample
   end

   fun {ToSample PartitionItem}
   %
   % Compute the sample of partition item.
   %
   % Args:
   %    PartitionItem
   %        Partition item to compute the sample of
   %
   % Return: (List(Float))
   %    Sample of the partition item
   % 
      case {Label PartitionItem}
      of note then {NoteSample PartitionItem}
      [] silence then {SilenceSample PartitionItem}
      [] '|' then 
         {ChordSample PartitionItem}
      else
         raise "The sample of this partition item has no been implemented" end
      end
   end
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                               Music Part                                  %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {PartitionToSample P2T P}
   %
   % Compute the sample of a full partition
   %
   % Args:
   %    P2T (Function)
   %        Function that returns the timed partition of a partition
   %    Partition
   %        Partition to compute the sample of
   %
   % Return: (List(Float))
   %    Sample of the partition
   % 
      {List.flatten {List.map {P2T P} ToSample}}
   end

   fun {MergeToSample P2T L}
   %
   % Compute the merge music part.
   %
   % Args:
   %    P2T (Function)
   %        Function that returns the timed partition of a partition
   %    L (List)
   %        List of tuple to merge
   %
   % Return: (List(Float))
   %    Merged sample
   % 
      fun {Aux X Acc}
         case X
         of nil then Acc 
         [] H|T then
            case H
            of F#M then {Aux T {ScaledVSum Acc 1.0 {Mix P2T M} F}}
            else {Show H} raise 'Wrong merge format' end
            end
         else {Show X} raise 'Wrong merge format' end
         end
      end
   in
      {Aux L nil}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                                 Filters                                   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Reverse Music}
   %
   % Reverse a music.
   %
   % Args:
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Reversed music
   %
      {List.reverse Music}
   end

   fun {Repeat N Music}
   %
   % Repeat a music N times.
   % If N is less than 1 an empty list is returned.
   %
   % Args:
   %    N (Int)
   %        Number of times to repeat the music
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Repeated Music
   %
      fun {Aux N Acc}
         if N < 1 then nil
         elseif N == 1 then Acc
         else {Aux N-1 {List.append Acc Music}}
         end
      end
   in
      {Aux N Music}
   end


   fun {Loop T Music}
   %
   % Loop trough a music for a certain time.
   % Music is cut when time is done.
   %
   % Args:
   %    T (Float)
   %        Number of seconds of looping
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Looped Music
   % 
      Length = {List.length Music}
      MusicTuple = {List.toTuple '#' Music}
      Sample = {List.make {Float.toInt (SamplingSize * T)}}
   in
      {List.forAllInd Sample proc {$ I Ai} Ai = MusicTuple.(((I-1) mod Length) + 1) end}
      Sample
   end


   fun {Clip Low High Music}
   %
   % Clip a music so it's elements are bounded to [Low, High] domain.
   % If a value is less than Low, it is changed to Low.
   % If a value if more than High, it is changed to High.
   %
   % Args:
   %    Low (Float)
   %        Lower bound of the clipping domain
   %    High (Float)
   %        Higher bound of the clipping domain
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Clipped Music
   % 
      fun {Aux X}
         if X < Low then Low
         elseif X > High then High
         else X
         end
      end 
   in
      {List.map Music Aux}
   end


   fun {Echo Delay Decay Music}
   %
   % Add an echo to a music with a given delay and a given decay.
   %
   % Args:
   %    Delay (Float)
   %        Delay between the start of music and its echo in second
   %    Decay (Float)
   %        Factor of decay of the echo
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Music with an echo
   % 
      %L = {List.length Music}
      SilenceSample = {List.make {Float.toInt Delay * SamplingSize}}
   in
      {List.forAll SilenceSample proc {$ Ai} Ai = 0.0 end}
      {ScaledVSum Music 1.0 {List.append SilenceSample Music} Decay}
   end

   fun {Fade Start Out Music}
   %
   % Fade the music using a trapezoidal enveloppe.
   %
   % Args:
   %    Start (Float)
   %        Duration of the in fade stops in seconds
   %    Out (Float)
   %        Duration of the out fade start in seconds
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Faded music
   %
      L = {List.length Music}
      StartMusic MiddleSample OutMusic
      {List.takeDrop {List.takeDrop Music {Float.toInt {Float.round Start * SamplingSize}} StartMusic} 
                     (L-{Float.toInt {Float.round (Start + Out) * SamplingSize}}) 
                     MiddleSample
                     OutMusic}
      StartFactor = {List.make {List.length StartMusic}}
      OutFactor = {List.make {List.length OutMusic}}
      StartSample OutSample
   in
      % Fading the end if the sample
      local
         % Affine Transformation f(x) = A*x + B
         % Such that f(L) = 0 and f(L-SamplingSize*Out) = 1
         B = 0.0
         A = 1.0/(SamplingSize*Start)
      in
         {List.forAllInd StartFactor proc {$ I Fi} Fi = A * {Int.toFloat I-1} + B end}
      end
      StartSample = {VMul StartMusic StartFactor}

      % Fading at the start of the sample
      local
         % Affine Transformation f(x) = A*x + B
         % Such that f(0) = 0 and f(SamplingSize*Start + 1) = 1
         B = 1.0
         A = ~1.0/(SamplingSize*Out)
      in
         {List.forAllInd OutFactor proc {$ I Fi} Fi = A * {Int.toFloat I} + B end}
      end
      OutSample = {VMul OutMusic OutFactor}
      {List.flatten [StartSample MiddleSample OutSample]}
   end

   fun {Cut Start Finish Music}
   %
   % Cut the music at a certain timing.
   %
   % Args:
   %    Start (Float)
   %        Time at wich the cut window starts in second.
   %    Finish (Float)
   %        Time at wich the cut window ends in second.
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Cut music
   %
      L = {List.length Music}
      Sample
      SilenceSample = {List.make {Max 0 ({Float.toInt (Finish) * SamplingSize} - L - 1)}}
   in
      {List.forAll SilenceSample proc {$ Ai} Ai = 0.0 end}
      {List.takeDrop {List.takeDrop Music ({Float.toInt Start * SamplingSize}) _} 
                     ({Float.toInt (Finish - Start) * SamplingSize}) 
                     Sample _}

      {List.append Sample SilenceSample}
   end 

   % Custom Filters

   fun {Siren MinF MaxF Spike Music}
   %
   % Create an alarm-like effect on the sound.
   % The transformation is done so loud notes are sharp
   % and low notes have a smooth transition.
   %
   % Args:
   %    MinF (Float)
   %        Level factor of the low notes
   %    MaxF (Float)
   %        Level factor of the loud notes
   %    Spike (Float)
   %        Number of spikes (loud notes) in the music
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Alarm-like music
   %

      % Coefficients of the transformation A * abs(cos(Bx + C)) + D
      L = {List.length Music}

      A = ~(MaxF-MinF)
      B = Pi*Spike/{Int.toFloat (L-1)}
      C = Pi
      D = ~A + MinF

      F = {List.mapInd Music fun{$ I _} A * {Number.abs {Float.cos B*{Int.toFloat I}+C}} + D end}
   in
      {VMul F Music}
   end

   fun {Vibrato Freq Decay Music}
   %
   % Add a vibrato effect to the music
   %
   % Args:
   %    Freq (Float)
   %        Frequence of the vibrato vibration
   %    Decay (Float)
   %        Decay level of the vibrato
   %    Music (List(Float))
   %        Music as a list of sample
   %
   % Return: (List(Float))
   %    Music with vibration
   %

      % Coefficients of the transformation A * cos(Bx + C) + D
      A = Decay/2.0
      B = 2.0*Pi*Freq/SamplingSize
      C = 0.0
      D = 1.0 - Decay/2.0

      F = {List.mapInd Music fun{$ I _} A * {Float.cos B*{Int.toFloat I}+C} + D end}
   in
      {VMul F Music}
   end

   fun{CrossFade T M1 M2}
      M1Faded = {Fade 0.0 T M1}
      M2Faded = {Fade T 0.0 M2}
      Silence = {List.make ({List.length M1} - {Float.toInt T*SamplingSize})}
   in
      {List.forAll Silence proc {$ Ai} Ai = 0.0 end}
      {ScaledVSum M1Faded 1.0 {List.append Silence M2Faded} 1.0}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                            Music handling tools                           %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {ScaledVSum X Fx Y Fy}
   %
   % Compute the sum of two scaled lists X and Y elementwise. 
   % Scaling is made elementwise.
   % If a list is smaller than the other, it is filled with 0.0.
   %
   % Args:
   %    X (List(Float))
   %        First list of floats
   %    Fx (Float)
   %        Scaling factor of X
   %    Y (List(Float))
   %        Second list of floats
   %    Fy (Float)
   %        Scaling factor of Y
   %
   % Return: (List(Float))
   %    Scaled sum Fx * X + Fy * Y
   % 
      Lx = {List.length X}
      Ly = {List.length Y}
      fun {Aux X Fx Y Fy}
         case X
         of nil then nil
         [] Hx|Tx then
            case Y
            of nil then Fx * Hx|{Aux Tx Fx Y Fy}
            [] Hy|Ty then (Fx * Hx+ Fy * Hy)|{Aux Tx Fx Ty Fy}
            end
         end
      end	    
   in
      if Ly > Lx then
         {Aux Y Fy X Fx}
      else
         {Aux X Fx Y Fy}
      end
   end

   fun {VMul X Y}
   %
   % Compute the multiplcation of two lists X and Y elementwise. 
   % Lists needs to be the same length.
   %
   % Args:
   %    X (List)
   %        First list
   %    Y (List)
   %        Second list
   %
   % Return: (List(Float))
   %    Scaled sum Fx * X + Fy * Y
   %  
      fun{Aux X Y}
         case X
         of nil then nil
         else X.1 * Y.1 |{Aux X.2 Y.2}
         end
      end
   in
      if {List.length X} \= {List.length Y} then raise 'Lists needs to be the same length' end end 
      {Aux X Y}
   end


   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                                  Mixing                                   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Mix P2T Music}
   %
   % Generate sound sample based on a Music. 
   %
   % Args:
   %    P2T (Function)
   %        Function converting partition to timed partition.
   %    Music (List)
   %        Music to generate the sample from
   %
   % Return: (List(Float))
   %    Sample of the music as a list of floats bound to [~1.0, 1.0].
   %  

      fun {Aux Part}
         MSample
      in
         case Part
         of samples(S)     then S
         [] partition(P)   then {PartitionToSample P2T P}
         [] wave(FileName) then {Project.readFile FileName}
         [] merge(L)       then {MergeToSample P2T L}
         else % Filters
            MSample = {Mix P2T Part.1}
            % Default Filters
            case Part
            of reverse(_)              then {Reverse MSample}
            [] repeat(amount:N _)      then {Repeat N MSample}
            [] loop(seconds:T _)       then {Loop T MSample}
            [] clip(low:L high:H _)    then {Clip L H MSample}
            [] echo(delay:T decay:F _) then {Echo T F MSample}
            [] fade(start:S out:O _)   then {Fade S O MSample}
            [] cut(start:S finish:F _) then {Cut S F MSample}
            % Custom Filters
            [] siren(minf:MinF maxf:MaxF spike:S _) then {Siren MinF MaxF S MSample}
            [] vibrato(frequency:Freq decay:D _)    then {Vibrato Freq D MSample}
            [] crossfade(seconds:T _ M2)            then
               local
                  M2Sample = {Mix P2T M2}
               in
                  {CrossFade T MSample M2Sample}
               end
            
            else {Show Part} raise 'Filter not Implemented' end
            end
         end
      end
   in
      {List.flatten {Map Music Aux}}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                            Boiler plate code                              %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Music = {Project.load 'sample/creative.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'test/tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [Length Fade Smoothing Reverse Repeat Loop Clip Echo Cut Length NoteToExtended SilenceSample ChordSample] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Music 'sample/creative.wav'}}
 
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
   {Browse ok}
end