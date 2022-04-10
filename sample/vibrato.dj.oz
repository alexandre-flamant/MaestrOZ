% Vibrato example
local
    Tune = [duration(seconds:3.0 [a])]
    Partition = partition(Tune)
 in
    % This is a music :)
    [Partition vibrato(decay:0.15 frequency:10.0 [Partition]) vibrato(decay:0.15 frequency:50.0 [Partition]) vibrato(decay:0.15 frequency:100.0 [Partition])]
 end