function drawStaffWithPitch(pitch, clef) {
    
    var zoomFactor = 4;
    width = window.innerWidth/zoomFactor;
    height = window.innerHeight/zoomFactor;
    var heightOffset = 60;
    
    VF = Vex.Flow;
    var div = document.getElementById("note")
    var svg = VF.Renderer.Backends.SVG
    var canvas = VF.Renderer.Backends.CANVAS
    var renderer = new VF.Renderer(div, svg);
    renderer.resize(window.innerWidth, height);
    var context = renderer.getContext();
    context.setFont("Arial", 10, "").setBackgroundFillStyle("#eed");
    
//    context.beginPath()
//    .moveTo(0, height * 0.5)
//    .lineTo(width, height * 0.5)
//    .stroke();
//    
//    context.beginPath()
//    .moveTo(width * 0.5, 0)
//    .lineTo(width * 0.5, height)
//    .stroke();
    
    var svgCanvas = document.getElementsByTagName("svg")[0];
    svgCanvas.setAttribute('style', 'zoom:' + (100 * zoomFactor) +'%;');
    
    var stave = new VF.Stave(width * 0.17, (height * 0.5) - heightOffset, width * 0.66);
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
        var note = new VF.StaveNote({clef: clef, keys: [letter+"/"+octave], duration: "w", align_center: true});
        if (accidental != null) {
            note = note.addAccidental(0, new VF.Accidental(accidental))
        }
        var notes = [note];
        var voice = new VF.Voice({num_beats: 4,  beat_value: 4});
        voice.addTickables(notes);
        var formatter = new VF.Formatter().joinVoices([voice]).format([voice], width * 0.34 - 22);
        
        voice.draw(context, stave);
    }
}
