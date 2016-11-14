function drawStaffWithPitch(pitch, clef, width, height) {
    VF = Vex.Flow;
    var div = document.getElementById("note")
    var renderer = new VF.Renderer(div, VF.Renderer.Backends.CANVAS);
    renderer.resize(width, height);
    var context = renderer.getContext();
    context.setFont("Arial", 10, "").setBackgroundFillStyle("#eed");
    
    var stave = new VF.Stave(25, 0, width-100);
    stave.addClef(clef);
    stave.setContext(context).draw();
    

    if (pitch != null) {
        var letter = pitch.charAt(0);
        var octave = pitch.charAt(pitch.length-1);
        var accidental;
        if (pitch.length == 3) {
            accidental = pitch.charAt(1);
        } else {
            accidental = null;
        }
        var note = new VF.StaveNote({clef: clef, keys: [letter+"/"+octave], duration: "w" });
        if (accidental != null) {
            note = note.addAccidental(0, new VF.Accidental(accidental))
        }
        var notes = [note];
        var voice = new VF.Voice({num_beats: 4,  beat_value: 4});
        voice.addTickables(notes);
        var formatter = new VF.Formatter().joinVoices([voice]).format([voice], 400);
        
        voice.draw(context, stave);
    }
}
