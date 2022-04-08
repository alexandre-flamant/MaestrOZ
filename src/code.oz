% Flamant Alexandre 5308 1500
local
   % See project statement for API details.
   [Project] = {Link ['src/Project2022.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime
   
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                             Control variables                             %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   Pi = 3.14159265359
   SamplingSize = 44100.0
   Smoothing = false % Implement smoothing ! 
   % Might implement Siren filter siren(minf:MinF maxF:MaxF spike:S Music)
   % Might implement Band stop filter bandStop(low:L high:H Music)
   % Might implement CrossFade filter crossFade(duration:T Music1 Music2)
   % Create Imperial march

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
   % Return:
   %    Extended Note
   %
      case Note
      of Name#Octave then
         note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      % This case was added for identity purpose.
      % That is if the input is already extended nothing is done
      [] silence(duration:D) then
         Note
      % This case was added for identity purposes.
      % That is if the input is already extended nothing is done
      [] note(name:N octave:O sharp:S duration:D instrument:I) then
         Note
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
   %        New duration of the partition in seconds.
   %    Partition (List)  
   %        Partition to which the transformation is applied on.
   % Return:
   %    Transformed partition
   %   

      InitT = {List.foldR Partition fun {$ PartitionItem T}
                                       case {Label PartitionItem}
                                       of note then T + PartitionItem.duration
                                       [] silence then T + PartitionItem.duration
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
   %
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
   %
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
   %
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
      ReversedPartition = {List.reverse Partition}
      FlatPartition = {NewCell nil}
   in
      for PartitionItem in ReversedPartition do
         case PartitionItem
         of duration(seconds:T P) then
            %{Browse 'duration'}
            FlatPartition := {List.append {Duration T {PartitionToTimedList P}} @FlatPartition}
         [] stretch(factor:F P) then
            %{Browse 'stretch'}
            FlatPartition := {List.append {Stretch F {PartitionToTimedList P}} @FlatPartition}
         [] drone(note:Note amount:N) then
            %{Browse 'drone'}
            FlatPartition := {List.append {Drone {ToExtended Note} N} @FlatPartition}
         [] transpose(semitones:N P) then
            %{Browse 'transpose'}
            FlatPartition := {List.append {Transpose N {PartitionToTimedList P}} @FlatPartition}
         else
            FlatPartition := {ToExtended PartitionItem}|@FlatPartition
         end   
      end
      @FlatPartition
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
   %       Note to compute the pitch of.
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
   %        Note to compute the frequency of..
   % Return: (Float)
   %    Frequency of the note.
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
   %        Note to compute the  sample of.
   % Return: (List(Float))
   %    Sample of the note.
   %  
      Sample = {NewCell nil}
      NoteFrequency = {Frequency Note}
   in
      for I in {Float.toInt {Float.round SamplingSize * Note.duration}}-1 .. 0; ~1 do
         Sample := 0.5 * {Float.sin (2.0 * Pi * NoteFrequency * {Int.toFloat I}/SamplingSize)}|@Sample
      end
      @Sample
   end


   fun {SilenceSample Silence}
   %
   % Compute the sample of a Silence.
   % Values ai of a silence is always equal to 0.0
   %
   % Args:
   %    Silence (ExtendedNote)
   %        Silence to compute the sample of.
   % Return: (List(Float))
   %    Sample of the Silence.
   %  
      Sample = {NewCell nil}
   in
      for I in {Float.toInt {Float.round SamplingSize * Silence.duration}}-1 .. 0; ~1 do
         Sample := 0.0|@Sample
      end
      @Sample
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
   %        Silence to compute the sample of.
   % Return: (List(Float))
   %    Sample of the Silence.
   % 

      Sample = {NewCell nil}
      Pi = 3.14159265359
      L = {Int.toFloat {List.length Chord}}
   in
      for I in {Float.toInt {Float.round SamplingSize * Chord.1.duration}}-1 .. 0; ~1 do
         local
            fun {Ai Note} 
               NoteFrequency = {Frequency Note}
            in
               0.5 * {Float.sin (2.0 * Pi * NoteFrequency * {Int.toFloat I}/SamplingSize)}
            end
         in
            Sample := ({List.foldR {Map Chord Ai} fun {$ X Y} X + Y end 0.0}/L)|@Sample
         end
      end
      @Sample
   end

   fun {ToSample PartitionItem}
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
   %                                 Filters                                   %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Reverse Music}
      {List.reverse Music}
   end

   fun {Repeat N Music}
      Sample = {NewCell Music}
   in
      for I in 1..(N-1) do
         Sample := {List.append @Sample Music}
      end
      @Sample
   end


   fun {Loop T Music}
      Length = {List.length Music}
      MusicTuple = {List.toTuple '#' Music}
      Sample = {NewCell nil}
   in
      for I in 1..{Float.toInt (SamplingSize * T)} do
         Sample := MusicTuple.((I mod Length +1))|@Sample 
      end
      {List.reverse @Sample}
   end


   fun {Clip Low High Music}
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
      L = {List.length Music}
      DelayedMusic = {NewCell Music}
   in
      for I in 1..{Float.toInt Delay * SamplingSize} do DelayedMusic := 0.0|@DelayedMusic end
      {ScaledVSum Music 1.0 @DelayedMusic Decay}
   end

   fun {Fade Start Out Music}
      L = {List.length Music}
      StartMusic MiddleSample OutMusic
      {List.takeDrop {List.takeDrop Music {Float.toInt Start * SamplingSize} StartMusic} 
                     (L-{Float.toInt (Start + Out) * SamplingSize}) 
                     MiddleSample
                     OutMusic}
      I = {NewCell 0.0}
      StartFactor = {List.make {List.length StartMusic}}
      OutFactor = {List.make {List.length OutMusic}}
      StartSample OutSample
   in
      % Fading the end if the sample
      I := 0.0
      local
         % Affine Transformation f(x) = A*x + B
         % Such that f(L) = 0 and f(L-SamplingSize*Out) = 1
         B = 0.0
         A = 1.0/(SamplingSize*Start)
      in
         for Ai in StartFactor do	 
            Ai = A * @I + B
            I := @I + 1.0
         end
      end
      StartSample = {VMul StartMusic StartFactor}

      % Fading at the start of the sample
      I := 1.0
      local
         % Affine Transformation f(x) = A*x + B
         % Such that f(0) = 0 and f(SamplingSize*Start + 1) = 1
         B = 1.0
         A = ~1.0/(SamplingSize*Out)
      in
         for Ai in OutFactor do	 
            Ai = A * @I + B
            I := @I + 1.0
         end
      end
      OutSample = {VMul OutMusic OutFactor}

      {List.flatten [StartSample MiddleSample OutSample]}
   end

   fun {Cut Start Finish Music}
      L = {List.length Music}
      Sample
      SilenceSample
   in
      {List.takeDrop {List.takeDrop Music ({Float.toInt Start * SamplingSize}) _} 
                     ({Float.toInt (Finish - Start) * SamplingSize - 1.0}) 
                     Sample _}
      SilenceSample = {List.make {Max 0 ({Float.toInt (Finish) * SamplingSize} - L - 1)}}
      for Ai in SilenceSample do Ai = 0.0 end
      {List.append Sample SilenceSample}
   end 

   fun {Siren MinF MaxF Spike Music}
      % Coefficients of the transformation A * cos(Bx + C) + D
      L = {List.length Music}

      A = ~(MaxF-MinF)
      B = Pi*Spike/{Int.toFloat (L-1)}
      C = Pi
      D = ~A + MinF

      F = {List.make L}
      I = {NewCell 0.0} % Non Declarative
   in
      for Fi in F do
         Fi = A * {Number.abs {Float.cos B*@I+C}} + D
         I:= @I + 1.0
      end
      {VMul F Music}
   end

   fun {Vibrato Freq Decay Music}
      L = {List.length Music}

      A = Decay/2.0
      B = 2.0*Pi*Freq/SamplingSize
      C = 0.0
      D = 1.0 - Decay/2.0

      F = {List.make L}
      I = {NewCell 0.0} % Non Declarative
   in
      for Fi in F do
         Fi = A * {Float.cos B*@I+C} + D
         I:= @I + 1.0
      end
      {VMul F Music}
   end

   fun {BandStop Low High Music}
      fun {Aux X} 
         if {And Low<X X<High} then 0.0
         else X
         end
      end 
   in
      {List.map Music Aux}
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                            Music handling tools                           %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {ScaledVSum X Fx Y Fy}
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
      Sample = {NewCell nil}
   in
      for Part in Music do
         case Part
         of sample(S) then
            Sample := {List.append @Sample S}
         [] partition(P) then
            local 
               Partition = {P2T P}
            in
               Sample := {List.append @Sample {List.flatten {List.map Partition ToSample}}}
            end
         [] wave(FileName) then
            Sample := {List.append @Sample {Project.readFile FileName}}
         [] merge(L) then
            local 
               R = {NewCell nil}
            in
               for Item in L do
                  case Item
                  of F#M then
                     R := {ScaledVSum @R 1.0 {Mix P2T M} F}
                  else  
                     {Show Item}
                     raise 'Wrong merge format' end
                  end 
               end
               Sample := {List.append @Sample @R}
            end
         [] reverse(M) then
            local 
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Reverse Msample}}
            end
         [] repeat(amount:N M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Repeat N Msample}}
            end
         [] loop(duration:T M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Loop T Msample}}
            end
         [] clip(low:L high:H M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Clip L H Msample}}
            end
         [] echo(delay:T decay:F M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Echo T F Msample}}
            end
         [] fade(start:S out:O M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Fade S O Msample }}
            end
         [] cut(start:S finish:F M) then

            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Cut S F Msample}}
            end
         % Custom Filter
         [] siren(minf:MinF maxf:MaxF spike:S M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Siren MinF MaxF S Msample}}
            end
         [] vibrato(frequency:Freq decay:D M) then
            local
               Msample = {Mix P2T M}
            in
               Sample := {List.append @Sample {Vibrato Freq D Msample}}
            end
         else  
            {Show Part}
            raise 'Not Implemented' end
         end
      end
      @Sample
   end

   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %                            Boiler plate code                              %
   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   %Music = {Project.load 'sample/joyfast.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   \insert 'test/tests.oz'
   % !!! Remove this before submitting.
in
   Start = {Time}

   % Uncomment next line to run your tests.
   {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [Length Fade Smoothing Reverse Repeat Loop Clip Echo Cut Length NoteToExtended SilenceSample ChordSample] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   %{Browse {Project.run Mix PartitionToTimedList Music 'sample/cat.wav'}}

   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
   {Browse ok}
end