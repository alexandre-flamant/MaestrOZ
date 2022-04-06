PassedTests = {Cell.new 0}
TotalTests  = {Cell.new 0}

% Time in seconds corresponding to 5 samples.
FiveSamples = 0.00011337868

% Takes a list of samples, round them to 4 decimal places and multiply them by
% 10000. Use this to compare list of samples to avoid floating-point rounding
% errors.
fun {Normalize Samples}
   {Map Samples fun {$ S} {IntToFloat {FloatToInt S*10000.0}} end}
end

proc {Assert Cond Msg}
   TotalTests := @TotalTests + 1
   if {Not Cond} then
      {System.show Msg}
   else
      PassedTests := @PassedTests + 1
   end
end

proc {AssertEquals A E Msg}
   TotalTests := @TotalTests + 1
   if A \= E then
      {System.show Msg}
      {System.show actual(A)}
      {System.show expect(E)}
   else
      PassedTests := @PassedTests + 1
   end
end

% Prevent warnings if these are not used.
{ForAll [FiveSamples Normalize Assert AssertEquals] Wait}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST PartitionToTimedNotes

proc {TestNotes P2T}
   Partition = [a5 b#4 silence c2]
   Expectation = [note(name:a octave:5 sharp:false duration:1.0 instrument:none)
             note(name:b octave:4 sharp:true duration:1.0 instrument:none)
             silence(duration:1.0)
             note(name:c octave:2 sharp:false duration:1.0 instrument:none)]
in
   {AssertEquals {P2T Partition} Expectation 'TestNotes failed'}
end

proc {TestChords P2T}
   Partition = [[a5 b#4 c2]]
   Expectation = [[note(name:a octave:5 sharp:false duration:1.0 instrument:none)
              note(name:b octave:4 sharp:true duration:1.0 instrument:none)
              note(name:c octave:2 sharp:false duration:1.0 instrument:none)]]
in
   {AssertEquals {P2T Partition} Expectation 'TestChords failed'}
end

proc {TestIdentity P2T}
   Partition = [note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                [note(name:a octave:5 sharp:false duration:1.0 instrument:none)
                note(name:b octave:4 sharp:true duration:1.0 instrument:none)
                note(name:c octave:2 sharp:false duration:1.0 instrument:none)]
                note(name:b octave:4 sharp:true duration:1.0 instrument:none)
                silence(duration:1.0)
                note(name:c octave:2 sharp:false duration:1.0 instrument:none)]
in
   {AssertEquals {P2T Partition} Partition 'TestIdentity failed'}
end

proc {TestDuration P2T}
   Partition = [duration(seconds:20.0 [a5 b#4 duration(seconds:2.0 [silence])]) c2 duration(seconds:4.0 [[a b]])]
   Expectation = [note(name:a octave:5 sharp:false duration:5.0 instrument:none)
                  note(name:b octave:4 sharp:true duration:5.0 instrument:none)
                  silence(duration:10.0)
                  note(name:c octave:2 sharp:false duration:1.0 instrument:none)
                  [note(name:a octave:4 sharp:false duration:4.0 instrument:none)
                   note(name:b octave:4 sharp:false duration:4.0 instrument:none)]]
in
   {AssertEquals {P2T Partition} Expectation 'TestIdentity failed'}
end

proc {TestStretch P2T}
   Partition = [stretch(factor:2.0 [a5 b#4 stretch(factor:2.6 [silence])]) c2]
   Expectation = [note(name:a octave:5 sharp:false duration:2.0 instrument:none)
                  note(name:b octave:4 sharp:true duration:2.0 instrument:none)
                  silence(duration:5.2)
                  note(name:c octave:2 sharp:false duration:1.0 instrument:none)]
in
   {AssertEquals {P2T Partition} Expectation 'TestStretch failed'}
end

proc {TestDrone P2T}
   Partition = [drone(note:e#5 amount:3) d drone(note:[e#3 g] amount:2) f8 drone(note:a amount:1) drone(note:c amount:0)]
   Expectation = [note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                  note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                  note(name:e octave:5 sharp:true duration:1.0 instrument:none)
                  note(name:d octave:4 sharp:false duration:1.0 instrument:none)
                  [note(name:e octave:3 sharp:true duration:1.0 instrument:none)
                   note(name:g octave:4 sharp:false duration:1.0 instrument:none)]
                  [note(name:e octave:3 sharp:true duration:1.0 instrument:none)
                   note(name:g octave:4 sharp:false duration:1.0 instrument:none)]
                  note(name:f octave:8 sharp:false duration:1.0 instrument:none)
                  note(name:a octave:4 sharp:false duration:1.0 instrument:none)]
in
   {AssertEquals {P2T Partition} Expectation 'TestDrone failed'}
end

proc {TestTranspose P2T}
   Partition = [transpose(semitones:1 [a#3 b4]) transpose(semitones:12 [[e g5] silence]) f]
   Expectation = [note(name:b octave:3 sharp:false duration:1.0 instrument:none)
                   note(name:c octave:5 sharp:false duration:1.0 instrument:none)
                   [note(name:e octave:5 sharp:false duration:1.0 instrument:none)
                    note(name:g octave:6 sharp:false duration:1.0 instrument:none)]
                   silence(duration:1.0)
                   note(name:f octave:4 sharp:false duration:1.0 instrument:none)]
in
   {AssertEquals {P2T Partition} Expectation 'TestTranspose failed'}
end

proc {TestP2TChaining P2T}
   Partition = [stretch(factor:1.5 
                        [duration(seconds:6.0
                                  [transpose(semitones:2 
                                             [drone(amount:3 note:[e g b])]
                                             )]
                                 )]
                        )]
   Expectation = [[note(name:f octave:4 sharp:true duration:3.0 instrument:none)
                   note(name:a octave:4 sharp:false duration:3.0 instrument:none)
                   note(name:c octave:5 sharp:true duration:3.0 instrument:none)]
                  [note(name:f octave:4 sharp:true duration:3.0 instrument:none)
                   note(name:a octave:4 sharp:false duration:3.0 instrument:none)
                   note(name:c octave:5 sharp:true duration:3.0 instrument:none)]
                  [note(name:f octave:4 sharp:true duration:3.0 instrument:none)
                   note(name:a octave:4 sharp:false duration:3.0 instrument:none)
                   note(name:c octave:5 sharp:true duration:3.0 instrument:none)]42]
in
   {AssertEquals {P2T Partition} Expectation 'TestP2TChaining failed'}
end

proc {TestEmptyChords P2T}
   Partition = [a b nil] % Empty list is nil
   Expectation = [note(duration:1 instrument:none name:a octave:4 sharp:false) 
                  note(duration:1 instrument:none name:b octave:4 sharp:false) 
                  nil] % So it should stay nil I guess
in
   {Show {P2T Partition}}
end
   
proc {TestP2T P2T}
   {TestNotes P2T}
   {TestChords P2T}
   {TestIdentity P2T}
   {TestDuration P2T}
   {TestStretch P2T}
   {TestDrone P2T}
   {TestTranspose P2T}
   {TestP2TChaining P2T}
   {TestEmptyChords P2T}   
   {AssertEquals {P2T nil} nil 'nil partition'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TEST Mix
proc {TestSamples P2T Mix}
   skip
end

proc {TestPartition P2T Mix}
   skip
end

proc {TestWave P2T Mix}
   skip
end

proc {TestMerge P2T Mix}
   skip
end

proc {TestReverse P2T Mix}
   skip
end

proc {TestRepeat P2T Mix}
   skip
end

proc {TestLoop P2T Mix}
   skip
end

proc {TestClip P2T Mix}
   skip
end

proc {TestEcho P2T Mix}
   skip
end

proc {TestFade P2T Mix}
   skip
end

proc {TestCut P2T Mix}
   skip
end

proc {TestMix P2T Mix}
   {TestSamples P2T Mix}
   {TestPartition P2T Mix}
   {TestWave P2T Mix}
   {TestMerge P2T Mix}
   {TestReverse P2T Mix}
   {TestRepeat P2T Mix}
   {TestLoop P2T Mix}
   {TestClip P2T Mix}
   {TestEcho P2T Mix}
   {TestFade P2T Mix}
   {TestCut P2T Mix}
   {AssertEquals {Mix P2T nil} nil 'nil music'}
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

proc {Test Mix P2T}
   {Property.put print print(width:100)}
   {Property.put print print(depth:100)}
   {System.show 'tests have started'}
   {TestP2T P2T}
   {System.show 'P2T tests have run'}
   {TestMix P2T Mix}
   {System.show 'Mix tests have run'}
   {System.show test(passed:@PassedTests total:@TotalTests)}
end