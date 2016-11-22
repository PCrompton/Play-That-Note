# Play That Note

## Overview

Play That Note is a flashcard game attempting to help music students learn to read music by displaying a musical note and "listening" with the device's microphone for the correct pitch. The student (user) is notified upon detection of a musical pitch as to whether the correct pitch was played or sung. Statistics are kept for the user's viewing, and also to inform the game engine how often to show individual flashcards. Flashcards with better statistics over time will be shown less often than others.

## Building/Running

Due to UI formatting issues, Play That Note currently only supports iPhone, although future iPad support is planned. To run the app, open up the xcode project file and build with Xcode like you would any other app. In order to play the game, Play That Note must be running on a physical device, as the pitch detection dependency "Beethoven" will crash in the simulator.

### Playing the Game

The user will be presented at launch with a menu view of four different clef images. To play, select the desired clef. A view with a blank music staff and statistics should appear. At the bottom of the screen, tap the "Start" button. A note will appear on the staff and the pitch engine is activated to detect a pitch. Play or sing a pitch and watch the statistics accumulate.

### Settings

To access the settings, tap the "Settings" button in the top right corner of the initial view controller. These settings help the user adjust the pitch detection configurations to optimize for the environment (i.e. noise pollution) or instrument being used.

* Consecutive Pitches control how many consecutive buffers must detect the same pitch to trigger user feedback.
* Buffer Size controls the number of audio frames per second a sample size uses to detect a pitch.
* Level Threshhold controls the amplitude of sounds under which pitch detection is ignored.

### Statistics

Statistics are grouped by clef. To view details of statistics for each clef, tap on the respective table cell. Tap the cell for an individual card to view the card and more statistical details for that card.

## Dependencies 

### Beethoven & Pitchy

For pitch detection, Play That Note relies on the open source framework Beethoven, which itself is dependent on another open source framework called Pitchy. Both can be found on Github:

* [Beethoven](https://github.com/vadymmarkov/Beethoven.git)
* [Pitchy](https://github.com/vadymmarkov/Pitchy.git)

### Vexflow

For displaying musical notation, Play That Note uses the Javascript library Vexflow, which can be found on Github:

* [Vexflow](https://github.com/vadymmarkov/Pitchy.git)

