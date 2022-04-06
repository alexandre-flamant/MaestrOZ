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
                   note(name:c octave:5 sharp:true duration:3.0 instrument:none)]]
in
   {AssertEquals {P2T Partition} Expectation 'TestP2TChaining failed'}
end

proc {TestEmptyChords P2T}
   % Empty list is nil
   Partition = [a b nil] 
   % So it should stay nil I guess
   Expectation = [note(duration:1.0 instrument:none name:a octave:4 sharp:false)
                  note(duration:1.0 instrument:none name:b octave:4 sharp:false)
                  nil]
in
   {AssertEquals {P2T Partition} Expectation 'TestEmptyChord failed'}
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
   Expectation = [0.5 0.4 0.3 0.2 0.1 0.0 ~0.1 ~0.2 ~0.3 ~0.4 ~0.5]
   Music = [sample(Expectation)]
in
   {AssertEquals {Mix P2T Music} Expectation 'TestSamples failed'}
end

proc {TestPartition P2T Mix}
   % Sound okay from test with actual partition
   Music = [partition([a b c d])]
   Sample
in
   Sample = {Mix P2T Music}
   % Test of the signal length
   {AssertEquals {List.length Sample} 4*44100 'TestPartition failed'}
end

proc {TestWave P2T Mix}
   Wav = 'wave/animals/cat.wav'
   Music = [wave(Wav)]
   Expectation = {Project.readFile Wav}
in
   {AssertEquals {Mix P2T Music} Expectation 'TestWave failed'}
end

proc {TestMerge P2T Mix}
   Music = [merge([0.5#[sample([1.0 0.8 1.0 0.4 0.2 0.0])] 
                   0.2#[sample([~1.0 ~1.0 ~1.0 ~1.0])]
                   0.06#[sample([1.0 1.0]) sample([1.0 1.0 1.0 1.0])]])]
   Expectation = [0.36 0.26 0.36 0.06 0.16 0.06]
   M
in
   %for X in {Mix P2T Music} do {Show {Float.is X}} end 
   {AssertEquals {Mix P2T Music} Expectation 'TestMerge failed'} %Seems to work but doesn't pass the tests ... -> Looks like floating point issue
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