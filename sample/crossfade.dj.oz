% CrossFade
local
    Wolf = [wave('wave/animals/wolf.wav')]
    Sheep = [wave('wave/animals/sheep.wav')]
 in
    % This is a music :)
    [crossfade(seconds:1.0 Wolf Sheep)]
 end