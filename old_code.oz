local
   %Flamant Alexandre 5308 1500
   %Hammer Leslie 
   [Project] = {Link ['Project2018.ozf']}
   Time = {Link ['x-oz://boot/Time']}.1.getReferenceTime
   
%%%%%%%%%%%%%%%%  PARTITION TEST  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   Z = [partition([duration(seconds:5.0 [a silence]) a])]

%%%%%%%%%%%%%%%%  FONCTION UTILITAIRES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Scale List Factor}
      local
	 fun {Scale2 X}
	    X*Factor
	 end
      in
	 {Map List Scale2}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Sum X Y}
      if {Length X}>={Length Y} then
	 case X
	 of nil then nil
	 [] Hx|Tx then
	    case Y
	    of nil then Hx|Tx
	    [] Hy|Ty then Hx+Hy|{Sum Tx Ty}
	    end

	 end
      else
	 {Sum Y X}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {SumAll L}   
      case L
      of H|T then
	 case T
	 of nil then H
	 else {SumAll {Sum H T.1}|T.2}
	 end
      end
   end

%%%%%%%%%%%%%%%%  VERICATION DE TYPE  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {IsSilence Silence}
      if Silence==silence then true
      else false
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {IsExtendedSilence Silence}
      if {Label Silence} == silence then
	 if {Arity Silence} == [duration] then true
	 else false
	 end
      else false
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {IsNote Note}
      case Note
      of nil then false
      [] H|T then false
      [] H#T then true
      [] Atom then
	 if {Label Atom} == duration then false
	 elseif {Label Atom} == transpose then false
	 elseif {Label Atom} == stretch then false
	 elseif {Label Atom} == drone then false
	 elseif {Label Atom} == note then false
	 else true
	 end
      else true
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun{IsChord Chord}
      case Chord
      of nil then true
      [] A|B then
	 if {IsNote A} then {IsChord B}
	 elseif {IsSilence A} then {IsChord B}
	 else false
	 end
      else false
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {IsExtendedNote ExtendedNote}
      if {Label ExtendedNote} == note then true
      else false
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {IsExtendedChord ExtendedChord}
      case ExtendedChord
      of nil then true
      [] H|T then
	 if {IsExtendedNote H} then {IsExtendedChord T}
	 elseif {IsExtendedSilence H} then {IsExtendedChord T}
	 else false
	 end
      else false
      end
   end

%%%%%%%%%%%%%%%%  CONVERTION EN EXTENDED  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {SilenceToExtended}
      silence(duration:1.0)
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {NoteToExtended Note}
      case Note
      of Name#Octave then
	 note(name:Name octave:Octave sharp:true duration:1.0 instrument:none)
      [] Atom then
	 case {AtomToString Atom}
	 of[_ _ _ _ _ _ _] then silence(duration:1.0)
	 [][_] then
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
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {ChordToExtended Chord}
      local
	 fun {F X}
	    if {IsSilence X} then {SilenceToExtended}
	    elseif {IsNote X} then {NoteToExtended X}
	    else false
	    end
	 end
      in	 
	 {Map Chord F}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {ItemToExtended Item}
      if {IsSilence Item} then [{SilenceToExtended}]
      elseif {IsNote Item} then [{NoteToExtended Item}]
      elseif {IsChord Item} then [{ChordToExtended Item}]
      elseif {Label Item} == duration then {Flatten {Duration {ItemToExtended Item.1} Item.seconds}}
      elseif {Label Item} == stretch then {Flatten {Stretch {ItemToExtended Item.1} Item.factor}}
      elseif {Label Item} == drone then {Flatten {Drone {ItemToExtended Item.note} Item.amount}}
      elseif {Label Item} == Transpose then {Transpose {ItemToExtended Item.1} Item.semitones}
      else Item
      end
   end

%%%%%%%%%%%%%%%%  TRANSFORMATIONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Transpose X H}
      local
	 fun {HauteurAbs Note}
	    local
	       VOctave
	       VName
	       VSharp
	    in 
	       VOctave=(Note.octave)*12
	       if Note.sharp then VSharp=1 else VSharp=0 end
	       if Note.name==c then VName=0
	       elseif Note.name==d then VName=2
	       elseif Note.name==e then VName=4
	       elseif Note.name==f then VName=5
	       elseif Note.name==g then VName=7
	       elseif Note.name==a then VName=9
	       elseif Note.name==b then VName=11
	       end
	       VOctave+VSharp+VName
	    end
	 end

	 fun {NName A}
	    if A == 0 then c
	    elseif A == 1 then c
	    elseif A == 2 then d
	    elseif A == 3 then d
	    elseif A == 4 then e
	    elseif A == 5 then f
	    elseif A == 6 then f
	    elseif A == 7 then g
	    elseif A == 8 then g
	    elseif A == 9 then a
	    elseif A == 10 then a
	    elseif A == 11 then b
	    end
	 end
	 fun {NSharp A}
	    if A == 1 then true
	    elseif A==3 then true
	    elseif A==6 then true
	    elseif A==8 then true
	    elseif A==10 then true
	    else false
	    end
	 end

	 fun {TransposeNote Note}
	    local
	       Ha = H+{HauteurAbs Note}
	    in
	       note(octave:(Ha div 12)
		    name: {NName (Ha mod 12)}
		    sharp: {NSharp (Ha mod 12)}
		    duration: Note.duration
		    instrument: Note.instrument)
	    end
	 end

	 fun {TransposeChord Chord}
	    local
	       fun {F X}
		  if {IsExtendedSilence X} then X
		  elseif {IsExtendedNote X} then {TransposeNote X}
		  end
	       end
	    in
	       {Map Chord F}
	    end
	 end
	  
	 fun {TransposeItem Item}
	    if {IsExtendedSilence Item} then Item
	    elseif {IsExtendedChord Item} then {TransposeChord Item}
	    elseif {IsExtendedNote Item} then {TransposeNote Item}
	    end
	 end
	  
      in
	 {Map X TransposeItem}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {Stretch X Factor}
      local
	 fun {StretchNote Note}
	    if {Label Note} == note then
	       note(duration:Note.duration*Factor
		    sharp:Note.sharp
		    instrument:Note.instrument
		    name:Note.name
		    octave:Note.octave)
	    end
	 end
	 
	 fun {StretchSilence Silence}
	    silence(duration:(Silence.duration*Factor))
	 end
	 
	 fun {StretchChord Chord}
	    local	       
	       fun {F Note}
		  if {IsExtendedSilence Note} then {StretchSilence Note}
		  elseif {IsExtendedNote Note} then {StretchNote Note}
		  else erreurStretchChord
		  end
	       end
	    in
	       {Map Chord F}
	    end
	 end
	 
	 fun {StretchItem Item}
	    if {IsExtendedChord Item} then {StretchChord Item}
	    elseif{IsExtendedNote Item} then {StretchNote Item}
	    elseif {IsExtendedSilence Item.1} then {StretchSilence Item.1}
	    else erreurStretchItem
	    end
	 end	 
	    
      in
	 {Map X StretchItem}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Drone Item Amount}
      if Amount=<0 then nil
      else Item|{Drone Item Amount-1}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {Duration Partition Time}
      local
	 NTime
	 fun {ChangeDurationNote Note}
	    note(duration:NTime
		 name:Note.name
		 sharp:Note.sharp
		 instrument:Note.instrument
		 octave:Note.octave)
	 end

	 fun {ChangeDurationChord Chord}
	    local
	       fun {F X}
		  if {IsExtendedSilence X} then {ChangeDurationSilence X}
		  elseif {IsExtendedNote X} then {ChangeDurationNote X}
		  else erreurChangeDurationChord
		  end
	       end	       
	    in
	       NTime = Time/{Int.toFloat {Length Chord}}
	       {Map Chord F}
	    end
	 end

	 fun {ChangeDurationSilence Silence}
	    silence(duration:NTime)
	 end

	 fun {ChangeDurationItem Item}
	    if {IsSilence Item.1} then {ChangeDurationSilence Item.1}
	    elseif {IsExtendedChord Item} then {ChangeDurationChord Item}
	    elseif {IsExtendedNote Item} then {ChangeDurationNote Item}
	    else erreurChangeDurationItem
	    end
	 end
      in
	 {Map Partition ChangeDurationItem}
      end
   end

%%%%%%%%%%%%%%%%  CONVERSION PARTITION SIMPLE EN EXTENDED  %%%%%%%%%%%%%%%%%%

   fun {PartitionToTimedList Partition}
      local
	 fun {FCT List}
	    case List
	    of nil then nil
	    [] H|T then {Append {ItemToExtended H} {FCT T}}
	    end
	 end
      in
	 case Partition
	 of H|T then {FCT Partition.1.1}
	 else {FCT Partition.1}
	 end
      end   
   end
   
%%%%%%%%%%%%%%%%  CALCUL ECHANTILLONS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {Hauteur Note}
      local VSharp VOctave VName
      in
	 if Note.sharp then VSharp=1.0 else VSharp=0.0 end
	 if Note.name == a then VName=0.0
	 elseif Note.name == b then VName=2.0
	 elseif Note.name == c then VName=~9.0
	 elseif Note.name == d then VName=~7.0
	 elseif Note.name == e then VName=~5.0
	 elseif Note.name == f then VName=~4.0
	 elseif Note.name == g then VName=~2.0
	 end
	 VOctave = {Int.toFloat Note.octave}*12.0
	 VSharp+VOctave+VName-48.0
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Frequence Note}
      {Number.pow 2.0 ({Hauteur Note}/12.0)}*440.0
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {EchantillonnageSilence Silence}
      local
	 Time=Silence.duration*44100.0
	 A ={NewCell nil}
      in
	 for Xi in 1..{Float.toInt Time} do
	    A:= 0.0|@A
	 end
	 {Reverse @A}
      end
   end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {EchantillonnageNote Note}
      local
	 Time=Note.duration*44100.0
	 A={NewCell nil}
	 Pi = 3.141592653589793
      in
	 if {Label Note} == silence then
	    for Xi in 1 .. {Float.toInt Time} do A:=0|@A end
	 else
	    for Xi in 1..{Float.toInt Time} do A:=(0.5*{Sin (2.0*Pi*{Int.toFloat Xi}*{Frequence Note}/44100.0)})|@A end
	 end
	 {Reverse @A}
      end
   end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {EchantillonnageChord Chord}
      local
	 Factor = 1.0/{Int.toFloat {Length Chord}}
	 fun {Scale List}
	    local
	       fun {Scale2 X}
		  X*Factor
	       end
	    in
	       {Map List Scale2}
	    end
	 end
	 
      in	 
	 {Scale {SumAll {Map Chord EchantillonnageNote}}}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {EchantillonnageSimpleItem Item}
      if {IsExtendedSilence Item} then {EchantillonnageSilence Item}
      elseif {IsExtendedNote Item} then {EchantillonnageNote Item}
      elseif {IsExtendedChord Item} then {EchantillonnageChord Item}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   fun {EchantillonnageItem Item}
      if {IsExtendedSilence Item} then {EchantillonnageSilence Item}
      elseif {IsExtendedNote Item} then {EchantillonnageNote Item}
      elseif {IsExtendedChord Item} then {EchantillonnageChord Item}
      else
	 if {Label Item} == merge then {Merge Item}
	 elseif {Label Item} == wav then {WavInput Item}
	 elseif {Label Item} == reverse then {Reverse {EchantillonnageItem Item}}
	 elseif {Label Item} == loop then {Loop {EchantillonnageItem Item} Item.seconds}
	 elseif {Label Item} == clip then {Clip {EchantillonnageItem Item} Item.low Item.high}
	 elseif {Label Item} == echo then {Echo {EchantillonnageItem Item} Item.delay Item.decay}
	 elseif {Label Item} == fade then {Fade {EchantillonnageItem Item} Item.start Item.out}
	 elseif {Label Item} == cut then {Cut {EchantillonnageItem Item} Item.start Item.finish}
	 elseif {Label Item} == repeat then {Repeat {EchantillonnageItem Item} Item.amount}
	 else erreurLabel
	 end
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Echantillonnage Music}
      {Map Music EchantillonnageItem}
   end

%%%%%%%%%%%%%%%%  FILTRES  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Repeat Music Amount}
      local
	 fun {Repeat2 Amount Music Acc}
	    if Amount==0 then {Flatten Acc}
	    else {Repeat2 Amount-1 Music Music|Acc}
	    end
	 end
      in
	 {Repeat2 Amount Music nil}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Clip Music Low High}
      local
	 fun {Clip2 Low High Music Acc}
	    case Music of nil then {Reverse Acc}
	    [] H|T then
	       if H<Low then {Clip2 Low High T Low|Acc}
	       elseif H>High then {Clip2 Low High T High|Acc}
	       else {Clip2 Low High T H|Acc}
	       end
	    end
	 end
      in
	 {Clip2 Low High Music nil}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Loop Music Time}
      local
	 Amount = {Float.toInt Time*44100.0}
	 MusicDuration = ({Int.toFloat{Length Music}}/44100.0)
	 MusicTime = {Float.toInt (((Time*44100.0)/MusicDuration)+1.0)}
	 TempMusic = {Repeat Music MusicTime}
	 fun {Cut List Amount}
	    if Amount == 0 then nil
	    else
	       case List
	       of nil then nil
	       [] H|T then H|{Cut T Amount-1}
	       end
	    end
	 end
      in
	 {Cut TempMusic Amount}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Cut Music Start Finish}
      local
	 StartAmount = {Float.toInt Start*44100.0}
	 FinishAmount = {Float.toInt Finish*44100.0}
	 fun {FrontCut Music Amount}
	    if Amount == 0 then Music
	    elseif Amount =<0 then {FrontCut 0.0|Music Amount+1}
	    else {List.drop Music Amount}
	    end
	 end
	 fun {BackCut Music Amount}
	    if Amount == {Length Music} then Music
	    elseif Amount >= {Length Music} then {BackCut {Append Music [0]} Amount}
	    else {List.take Music Amount}
	    end
	 end
      in
	 {FrontCut {BackCut Music FinishAmount} StartAmount}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Fade Music Start Finish}
      local
	 Duration = {Int.toFloat {Length Music}}
	 DurationAmount = {Float.toInt (Duration)*44100.0}
	 StartAmount = {Float.toInt Start*44100.0}
	 FinishAmount = {Float.toInt Finish*44100.0}
	 StartScale = {NewCell nil}
	 StartList = {List.take Music StartAmount}
	 FinishScale = {NewCell nil}
	 FinishList = {List.drop Music (DurationAmount-FinishAmount)}
	 MidList = {Cut Music Start (Duration-Finish)}
	 fun {Mult X Y}
	    case X
	    of nil then nil
	    [] H1|T1 then
	       case Y
	       of nil then nil
	       [] H2|T2 then (H1*H2)|{Mult T1 T2}
	       end
	    end
	 end
      in
	 
	 for Xi in 1..{Length StartList} do
	    StartScale:={Int.toFloat Xi}|@StartScale
	 end
	 
	 for Xi in 1..{Length FinishList} do
	    FinishScale:={Int.toFloat Xi}|@FinishScale
	 end
	 StartScale:={Scale {Reverse @StartScale} (1.0/{Int.toFloat {Length @StartScale}})}
	 FinishScale:={Scale @FinishScale (1.0/{Int.toFloat {Length @FinishScale}})}
	 {Flatten [{Mult @StartScale StartList} MidList {Mult @FinishScale FinishList}]}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Echo Music Delay Decay}
      local
	 fun {Sum X Y}
	    if {Length X}>={Length Y} then
	       case X
	       of nil then nil
	       [] Hx|Tx then
		  case Y
		  of nil then Hx|Tx
		  [] Hy|Ty then Hx+Hy|{Sum Tx Ty}
		  end

	       end
	    else
	       {Sum Y X}
	    end
	 end
	 Silence = {Repeat [0.0] {Float.toInt Delay*44100.0}}
	 EchoSound = {Append Silence {Scale Music Decay}}
      in
	 {Sum Music EchoSound}
      end
   end

%%%%%%%%%%%%%%%%  GESTION D'INPUT PARTICULIERS  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {Merge MergeList}
      local
	 fun {ScaleSound Sound}
	    case Sound
	    of A#B then
	       {Scale B {EchantillonnageSimpleItem A}}
	    end
	 end
      in
	 {SumAll {Map MergeList.1 ScaleSound}} 
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   fun {WavInput WavFile}
      {Project.load WavFile}
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %Suffit pour des partitions simples
   fun {Mix P2T Music}
      local
	 FlatPart
      in
	 FlatPart = {P2T Music}
	 {Flatten {Echantillonnage FlatPart}}
	 %{Project.readFile 'wave/animaux/cow.wav'}
      end
   end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
   %Music = {Project.load 'joy.dj.oz'}
   Start

   % Uncomment next line to insert your tests.
   % \insert 'tests.oz'
   % !!! Remove this before submitting.
   
in
   /*
   Start = {Time}

   % Uncomment next line to run your tests.
   % {Test Mix PartitionToTimedList}

   % Add variables to this list to avoid "local variable used only once"
   % warnings.
   {ForAll [NoteToExtended Z] Wait}
   
   % Calls your code, prints the result and outputs the result to `out.wav`.
   % You don't need to modify this.
   {Browse {Project.run Mix PartitionToTimedList Z 'Out.wav'}}
   
   % Shows the total time to run your code.
   {Browse {IntToFloat {Time}-Start} / 1000.0}
   */
   %{Browse {PartitionToTimedList Z}}
   skip
end