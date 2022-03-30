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
         initT = {Record.foldR Partition fun {$ Note T} T + Node.duration end 0}
         fun {Aux L Acc}
            case L
            of nil then nil
            [] H|T then {Record.adjoinAt H duration (H.duration * T/initT)}|{Aux T}
            end
         end
      in
         {Aux Partition}         
      end
      
      fun {stretch F Partition} 
         fun {Aux L Acc}
            case L
            of nil then nil
            [] H|T then {Record.adjoinAt H duration (F * H.duration)}|{Aux T}
            end
         end
      in
         {Aux Partition}
      end
      
      fun {Drone N Note} 
         if N<=0 then nil
         else Note|{Drone (N-1) Note}
         end
      end

      fun {Transpose N Partition} 
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

         fun {Aux N L}
            I
            NewNote
         in
            case L
            of nil then nil
            [] H|T then 
               I = {Index H}
               NewNote = {List.nth Notes (I+N) mod 12}
               {Record.adjoinAt {Record.adjoinAt {Record.adjoinAt H name NewNote.name} sharp NewNote.sharp} ((I+N) div 12)}|{Aux T}
            end
         end
      in
         {Aux N Partition}
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