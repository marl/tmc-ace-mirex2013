function idx = bpm2idx(bpm, ref, octave_divider) 

idx = round((log2(bpm) - log2(ref)) .* octave_divider) + 1;