% Ode To Joy
local
   Tune = [stretch(factor:0.25 [b b c5 d5 d5 c5 b a g g a b])]
   End1 = [stretch(factor:1.5/4.0 [b]) stretch(factor:0.5/4.0 [a]) stretch(factor:2.0/4.0 [a])]
   End2 = [stretch(factor:1.5/4.0 [a]) stretch(factor:0.5/4.0 [g]) stretch(factor:2.0/4.0 [g])]
   Interlude = [stretch(factor:0.25 [a a b g a]) stretch(factor:0.5/4.0 [b c5])
                stretch(factor:0.25 [b g a]) stretch(factor:0.5/4.0 [b c5])
                stretch(factor:0.25 [a g a]) stretch(factor:2.0/4.0 [d]) ]

   % This is not a music.
   Partition = [duration(seconds:25.0 {Flatten [Tune End1 Tune End2 Interlude Tune End2]})]
in
   % This is a music :)
   [partition(Partition)]
end