local 
    Notes =  [g4 g4 g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4])
              g4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4]) d5
              d5 d5 stretch(factor:0.750 [d#5]) stretch(factor:0.250 [a#4]) f#4
              stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4]) g5 stretch(factor:0.750 [g4])
              stretch(factor:0.250 [g4]) g5 stretch(factor:0.750 [f#5]) stretch(factor:0.250 [f5]) stretch(factor:0.250 [e5])
              stretch(factor:0.250 [d#5]) stretch(factor:0.500 [e5]) stretch(factor:0.500 [silence]) stretch(factor:0.500 [g#4]) c#5
              stretch(factor:0.750 [c4]) stretch(factor:0.250 [b4]) stretch(factor:0.250 [a#4]) stretch(factor:0.250 [a4]) stretch(factor:0.500 [a#4])
              stretch(factor:0.500 [silence]) stretch(factor:0.500 [d#4]) f#4 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4])
              g5 stretch(factor:0.750 [d#4]) stretch(factor:0.250 [a#4]) stretch(factor:2.000 [g4])]

in
    [partition([duration(seconds:25.0 Notes)])]
end