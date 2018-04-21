


function higherPitch(firstPitch, secondPitch) {
    var firstOctave = Number(firstPitch.charAt(firstPitch.length-1));
    var secondOctave = Number(secondPitch.charAt(secondPitch.length-1));
    
    if (firstOctave > secondOctave) {
        return [1, 0]
    } else if (firstOctave < secondOctave) {
        return [0, 1]
    } else {
        pitches = ["C", "D", "E", "F", "G", "A", "B"];
        var firstLetter = firstPitch.charAt(0);
        var secondLetter = secondPitch.charAt(0);
        
        if (pitches.indexOf(firstLetter) > pitches.indexOf(secondLetter)) {
            return [1, 0]
        } else if (pitches.indexOf(firstLetter) < pitches.indexOf(secondLetter)){
            return [0, 1]
        } else {
            var firstAccidental;
            if (firstPitch.length == 3) {
                firstAccidental = firstPitch.charAt(1);
            } else {
                firstAccidental = [0,0];
            }
            
            var secondAccidental;
            if (secondPitch.length == 3) {
                secondAccidental = secondPitch.charAt(1);
            } else {
                secondAccidental = [0,0];
            }
            
            if (firstAccidental != secondAccidental) {
                if (firstAccidental == "#") {
                    return [1, 0]
                } else if (firstAccidental == "b") {
                    return [0, 1]
                } else {
                    return [0,0];
                }
            } else {
                return [0,0];
            }
        }
    }
}

function drawStaffWithPitch(pitch, clef, zoomFactor=4, secondPitch) {
    console.log("drawStaffWithPitch");
    width = window.innerWidth/zoomFactor;
    height = window.innerHeight/zoomFactor;
    var heightOffset = 60;
    
    VF = Vex.Flow;
    var div = document.getElementById("note")
    var svg = VF.Renderer.Backends.SVG
    var renderer = new VF.Renderer(div, svg);
    renderer.resize(window.innerWidth, height);
    var context = renderer.getContext();
    context.setFont("Arial", 10, "").setBackgroundFillStyle("#eed");
    
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
        var note;
        var higher = [0,0]
        if (secondPitch != null) {
            higher = higherPitch(pitch, secondPitch);
            console.log("higher", higher);
            var secondLetter = secondPitch.charAt(0);
            var secondOctave = secondPitch.charAt(secondPitch.length-1);
            var secondAccidental;
            if (secondPitch.length == 3) {
                secondAccidental = secondPitch.charAt(1);
            } else {
                secondAccidental = null;
            }

            note = new VF.StaveNote({clef: clef, keys: [letter+"/"+octave, secondLetter+"/"+secondOctave], duration: "w", align_center: true});
            
            var redStyle = {
                fillStyle: "red",
                strokeStyle: "red"
            };
            
            note.setKeyStyle(higher[1], redStyle);
            if (secondAccidental != null) {
                note = note.addAccidental(higher[1], new VF.Accidental(secondAccidental))
            }
        } else {
            note = new VF.StaveNote({clef: clef, keys: [letter+"/"+octave], duration: "w", align_center: true});
        }

        if (accidental != null) {
            note = note.addAccidental(higher[0], new VF.Accidental(accidental))
        }
        var notes = [note];

        var voice = new VF.Voice({num_beats: 4,  beat_value: 4});
        voice.addTickables(notes);
        var formatter = new VF.Formatter().joinVoices([voice]).format([voice], width * 0.34 - 22);
        voice.draw(context, stave);
    }
}
