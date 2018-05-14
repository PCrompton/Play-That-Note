


function sort(pitchObjects) {
    pitchObject1 = pitchObjects[0];
    pitchObject2 = pitchObjects[1];
    
    var octave1 = Number(pitchObject1.octave);
    var octave2 = Number(pitchObject2.octave);
    
    if (octave1 > octave2) {
        return [pitchObject2, pitchObject1]
    } else if (octave1 < octave2) {
        return [pitchObject1, pitchObject2]
    }
    pitches = ["C", "D", "E", "F", "G", "A", "B"];
    console.log(pitchObject1.letter, pitchObject2.letter);
    if (pitches.indexOf(pitchObject1.letter) > pitches.indexOf(pitchObject2.letter)) {
        return [pitchObject2, pitchObject1]
    } else if (pitches.indexOf(pitchObject1.letter) < pitches.indexOf(pitchObject2.letter)){
        return [pitchObject1, pitchObject2]
    }
    if (pitchObject1.accidental != pitchObject2.accidental) {
        if (pitchObject1.accidental == "#") {
            return [pitchObject2, pitchObject1]
        } else if (pitchObject1.accidental == "b") {
            return [pitchObject1, pitchObject2]
        }
    }
    return [pitchObject1, pitchObject2];
}

function getKeys(pitches) {
    var keys = [];
    pitches.forEach(function (pitch) {
                    keys.push(pitch.key);
                    });
    return keys;
}

function pitchKey(pitch) {
    return getLetter(pitch)+"/"+getOctave(pitch)
}

function getLetter(pitch) {
    return letter = pitch.charAt(0);
}

function getOctave(pitch) {
    return pitch.charAt(pitch.length-1);
}

function getAccidental(pitch) {
    var accidental;
    if (pitch.length == 3) {
        accidental = pitch.charAt(1);
    } else {
        accidental = null;
    }
    return accidental
}

function noteObject(pitch) {
    return {
        "letter": getLetter(pitch),
        "octave": getOctave(pitch),
        "accidental": getAccidental(pitch),
        "key": pitchKey(pitch)
    }
}

function addAccidentals(note, pitches) {
    for (i=0; i<pitches.length; i++) {
        var pitch = pitches[i];
        if (pitch.accidental != null) {
            note.addAccidental(i, new VF.Accidental(pitch.accidental))
        }
    }
    //add naturals
    if (pitches.length == 2) {
        pitch1 = pitches[0];
        pitch2 = pitches[1];
        
        if (pitch1.letter == pitch2.letter && pitch1.accidental != pitch2.accidental) {
            
            pitches.forEach(function (pitch) {
                            var index = pitches.indexOf(pitch);
                            if (pitch.accidental == null) {
                                note.addAccidental(index, new VF.Accidental("n"));
                            }
                            });

        }
    }
    return note;
}

function addStyles(note, pitches) {
    for (i=0; i<pitches.length; i++) {
        var style = {
            fillStyle: pitches[i].color,
            strokeStyle: pitches[i].color
        };
        note.setKeyStyle(i, style);
    }
    return note;
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
    console.log("stave_length", stave.width)
    stave.addClef(clef);
    stave.setContext(context).draw();
    
    if (pitch != null) {
        var pitchObject = noteObject(pitch);
        pitchObject.color = "black";
        var pitches = [pitchObject];
        if (secondPitch != null) {
            pitchObject2 =  noteObject(secondPitch);
            pitchObject2.color = "red";
            pitches.push(pitchObject2);
            pitches = sort(pitches);
        }
        console.log(pitches);
        console.log(getKeys(pitches));
        note = new VF.StaveNote({clef: clef, keys: getKeys(pitches), duration: "w", align_center: true});
        
        note = addAccidentals(note, pitches);
        note = addStyles(note, pitches);
        note.width = stave.width;
        var notes = [note];
        console.log("context:", note.context);
        var voice = new VF.Voice({num_beats: 1,  beat_value: 1});
        voice.addTickables(notes);
        var formatter = new VF.Formatter()
        formatter.joinVoices([voice])
        formatter.format([voice]);
        var minTotalWidth = formatter.getMinTotalWidth();
        formatter.format([voice], width * 0.34 - 22);
        voice.draw(context, stave);
    }
}
