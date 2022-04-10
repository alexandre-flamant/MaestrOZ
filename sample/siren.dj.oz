% Siren example

local
    Tune = [duration(seconds:4.0 [a])]
    Partition = partition(Tune)
 in
    % This is a music :)
    [Partition siren(minf:0.5 maxf:1.0 spike:2.0 [Partition]) siren(minf:0.25 maxf:1.5 spike:2.0 [Partition]) siren(minf:0.01 maxf:2.0 spike:2.0 [Partition])]
 end