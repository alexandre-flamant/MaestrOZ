% Siren example
local
    Tune = [duration(seconds:2.0 [[a b c d e f g]])]
    Partition = partition(Tune)
 in
    % This is a music :)
    [Partition bandstop(low:~0.05 high:0.05 [Partition])
               bandstop(low:~0.1 high:0.1 [Partition])
               bandstop(low:~0.15 high:0.15 [Partition])]
 end