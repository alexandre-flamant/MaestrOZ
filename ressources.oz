%Possible notes
Notes = [note(name:c sharp:false)
         note(name:c sharp:true)
         note(name:d sharp:false)
         note(name:d sharp:true)
         note(name:e sharp:false)
         note(name:f sharp:false)
         note(name:f sharp:true)
         note(name:g sharp:false)
         note(name:g sharp:true)
         note(name:a sharp:false)
         note(name:a sharp:true)
         note(name:b sharp:false)]

%Example of extended notations
Note = note(name:a octave:8 sharp:true duration:2.4 instrument:violon)
Chord = chord(note(name:a octave:8 sharp:true duration:2.4 instrument:piano)
              note(name:a octave:7 sharp:true duration:2.4 instrument:violon)
              note(name:a octave:6 sharp:true duration:2.4 instrument:guitar))