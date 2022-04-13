% John Williams' "The Imperial March"
local
    % Première main
    Hand1Chore1  = [g4 g4 g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4])
                    g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4]) d5
                    d5 d5 stretch(factor:0.750 [d#5]) stretch(factor:0.250 [a#4]) f#4
                    stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4]) g5 stretch(factor:0.750 [g4])
                    stretch(factor:0.250 [g4]) g5 stretch(factor:0.750 [f#5]) stretch(factor:0.250 [f5]) stretch(factor:0.250 [e5])
                    stretch(factor:0.250 [d#5]) stretch(factor:0.500 [e5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [g#4]) c#5
                    stretch(factor:0.750 [c5]) stretch(factor:0.250 [b4]) stretch(factor:0.250 [a#4]) stretch(factor:0.250 [a4]) stretch(factor:0.500 [a#4])
                    stretch(factor:0.500 [silence]) stretch(factor:0.500 [d#4]) f#4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [f#4])
                    a#4 stretch(factor:0.750 [g4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [d5]) g5
                    stretch(factor:0.750 [g4]) stretch(factor:0.250 [g4]) g5 stretch(factor:0.750 [f#5]) stretch(factor:0.250 [f5])
                    stretch(factor:0.250 [e5]) stretch(factor:0.250 [d#5]) stretch(factor:0.500 [e5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [g#4])
                    c#5 stretch(factor:0.750 [c5]) stretch(factor:0.250 [b4]) stretch(factor:0.250 [a#4]) stretch(factor:0.250 [a4])
                    stretch(factor:0.500 [a#4]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [d#4]) f#4 stretch(factor:0.750 [d#4])
                    stretch(factor:0.250 [a#4]) g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4])]
    
    
    Hand1Chore2 =  [g4 g4 g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4])
                    g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4]) d5
                    d5 d5 stretch(factor:0.750 [d#5]) stretch(factor:0.250 [a#4]) f#4
                    stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4]) g5 stretch(factor:0.750 [g4])
                    stretch(factor:0.250 [g4]) g5 stretch(factor:0.750 [f#5]) stretch(factor:0.250 [f5]) stretch(factor:0.250 [e5])
                    stretch(factor:0.250 [d#5]) stretch(factor:0.500 [e5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [g#4]) c#5
                    stretch(factor:0.750 [c4]) stretch(factor:0.250 [b4]) stretch(factor:0.250 [a#4]) stretch(factor:0.250 [a4]) stretch(factor:0.500 [a#4])
                    stretch(factor:0.500 [silence]) stretch(factor:0.500 [d#4]) f#4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4])
                    g5 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4])]

    Hand1Coda1    = [stretch(factor:0.500 [silence]) stretch(factor:0.500 [d5]) stretch(factor:0.500 [d#5]) stretch(factor:0.500 [c5]) stretch(factor:0.500 [silence])
                     stretch(factor:0.500 [a#5]) stretch(factor:0.500 [a5]) stretch(factor:0.500 [f#5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [d6])
                     stretch(factor:0.500 [c#6]) stretch(factor:0.500 [a5]) stretch(factor:0.500 [c6]) stretch(factor:0.500 [a#5]) stretch(factor:0.500 [f#5])
                     stretch(factor:0.500 [d#5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [d5]) stretch(factor:0.500 [d#5]) stretch(factor:0.500 [c5])
                     stretch(factor:0.500 [silence]) stretch(factor:0.500 [a#5]) stretch(factor:0.500 [a5]) stretch(factor:0.500 [f#5]) stretch(factor:0.500 [silence])
                     stretch(factor:0.500 [g6]) stretch(factor:0.500 [d6]) stretch(factor:0.500 [a#5]) stretch(factor:0.500 [g#5]) stretch(factor:0.500 [d#5])
                     stretch(factor:0.500 [b4]) stretch(factor:0.500 [g#4])]

    Hand1Coda2    = [stretch(factor:0.500 [silence]) stretch(factor:0.500 [d5]) stretch(factor:0.500 [d#5]) stretch(factor:0.500 [c5]) stretch(factor:0.500 [silence])
                     stretch(factor:0.500 [a#5]) stretch(factor:0.500 [a5]) stretch(factor:0.500 [f#5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [d6])
                     stretch(factor:0.500 [c#6]) stretch(factor:0.500 [a5]) stretch(factor:0.500 [c6]) stretch(factor:0.500 [a#5]) stretch(factor:0.500 [f#5])
                     stretch(factor:0.500 [d#5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [d5]) stretch(factor:0.500 [d#5]) stretch(factor:0.500 [c5])
                     stretch(factor:0.500 [silence]) stretch(factor:0.500 [a#5]) stretch(factor:0.500 [a5]) stretch(factor:0.500 [f#5]) stretch(factor:0.500 [silence])
                     stretch(factor:0.500 [g6]) stretch(factor:0.500 [d6]) stretch(factor:0.500 [a#5]) stretch(factor:0.500 [g#5]) stretch(factor:0.500 [d#5])
                     stretch(factor:0.500 [b4]) stretch(factor:0.500 [g#4])]
                
    Hand1Final    = [g5 stretch(factor:0.750 [g4]) stretch(factor:0.250 [g4]) g5 stretch(factor:0.750 [f#5])
                     stretch(factor:0.250 [f5]) stretch(factor:0.250 [e5]) stretch(factor:0.250 [d#5]) stretch(factor:0.500 [e5]) stretch(factor:0.500 [silence])
                     stretch(factor:0.500 [g#4]) c#5 stretch(factor:0.750 [c5]) stretch(factor:0.250 [b4]) stretch(factor:0.250 [a#4])
                     stretch(factor:0.250 [a4]) stretch(factor:0.500 [a#4]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [d#4]) f#4
                     stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4])
                     g4]
    
    % Second hand

    Hand2Chore1 = [g2 g2 g2 d#2 g2
                    d#2 g2 g2 g2 g2
                    g2 d#2 d#2 d#2 g2
                    g2 g2 g2 g2 g2
                    c#2 c#2 c#2 c#2 d#2
                    d#2 d#2 d#2 g2 d#2
                    g2 g2 d#2 d#2 g2
                    g2 c#2 c#2 c#2 c#2
                    d#2 d#2 d#2 d#2 g2
                    c2 g2 g2]
    Hand2Chore2 = [g2 g2 g2 d#2 g2
                    d#2 g2 g2 g2 g2
                    g2 d#2 d#2 d#2 g2
                    g2 g2 g2 g2 g2
                    c#2 c#2 c#2 c#2 d#2
                    d#2 d#2 d#2 g2 d#2
                    stretch(factor:2.000 [g2])]
    Hand2Coda1 = [stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4])
                  stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4])]

    Hand2Coda2 =[stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4])
                stretch(factor:2.000 [d4]) stretch(factor:2.000 [d4]) stretch(factor:2.000 [d3])]
    
    Hand2Final = [d#2 d#2 g2 g2 c#2
                c#2 c#2 c#2 d#2 d#2
                d#2 d#2 d#2 g2 d#2
                stretch(factor:2.000 [g2])]
    

    Hand1Partition = {List.flatten [Hand1Chore1 Hand1Chore1 Hand1Coda1 Hand1Coda2 Hand1Final]}
    Hand2Partition = [transpose(semitones:12 {List.flatten [Hand2Chore1 Hand2Chore1 Hand2Coda1 Hand2Coda2 Hand2Final]})]
    
in
    [merge([
            1.0#[partition([duration(seconds:0.90 * 93.0 Hand1Partition)])]
            0.9#[partition([duration(seconds:0.90 * 93.0 Hand2Partition)])]
            ])]
end