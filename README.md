Chord Scale Matrix for SuperCollider
====================================

Status
------
ChordScaleMatrix is a step sequencer. You can create scales and random notes of a scale in a matrix window. You can also create chord progessions on selected cells in the matrix window. ChordScaleMatrix is an application for creative working with the music theory of chords, scales, tunings and progressions. You are able to send to an other MIDI device. ChordScaleMatrix is a fork of [Rukano's step sequencer](http://sccode.org/1-Up). ChordScaleMatrix is OSS. ChordScaleMatrix is beta. :-( ;-)

[![ScreenShot](https://github.com/exesdotnet/ChordScaleMatrix/blob/master/screenshot-csm.png)](https://github.com/exesdotnet/ChordScaleMatrix/)

Usecases
--------
* Learning software for understanding the music theory of chords, chord progressions, scales and tuning
* Therapeutic effect by playing and learning
* A funny toy for just having fun and to promote creativity
* Audio and music analysis
* etc.

Installation
------------

Requirements

* [SuperCollider](http://supercollider.sourceforge.net/downloads/) (version 3.5 or later)
* [ChordSymbol](https://github.com/triss/ChordSymbol)
* [modfm-synth](https://github.com/filib/modfm-synth) (MIDI keyboard)


* [SuperCollider on Github](https://github.com/supercollider/supercollider)
* [SuperCollider plugins on Github](https://github.com/supercollider/sc-plugins)
* [SuperCollider help](http://doc.sccode.org/Help.html)

### Windows

Using the zipped release file

* Download latest release [ChordScaleMatrix](https://github.com/exesdotnet/ChordScaleMatrix/releases) 0.90 beta or later!
Alternative the [zipped Git repository](https://github.com/exesdotnet/ChordScaleMatrix/archive/master.zip)
* Download the [ChordSymbol](https://github.com/triss/ChordSymbol/archive/master.zip) extension!
* Download the [modfm-synth](https://github.com/filib/modfm-synth/archive/master.zip) MIDI keyboard extension!
* Please copy the extensions in the SuperCollider extension folder! You can examine by typing `Platform.userExtensionDir.postln;` in the IDE.
* Open the IDE!
* In the menu `Language` click `Recompile Class Library`!
* Open in SuperCollider IDE the file `ChordScaleMatrix\ChordScaleMatrix.scd`!
* Click betweenn the parenthesis!
* Press `Strg + Return` to run the SuperCollider document!

### Linux

Using the zipped release file

[Same procedure like in Windows](https://github.com/exesdotnet/ChordScaleMatrix/blob/master/README.md#windows)

Install via script by typing!

    # Installation script
    cd ChordScaleMatrix
    ./install-csm.sh
    
Install via script using Git!

    # Installation using Git
    cd ChordScaleMatrix
    ./install-csm.sh --git

Running
-------

**Manually**

Once SupperCollider is loaded you can open `ChordScaleMatrix/install_ChordScaleMatrix.scd` 
in case not all requirements are installed.

Open `ChordScaleMatrix/ChordScaleMatrix.scd` and click between the parenthesis 
and press `Strg + Return` to run the SuperCollider document!

**Automatically**

Start SuperCollider by running `run-csm.sh`!

    # Running
    cd ChordScaleMatrix
    ./run-csm.sh
    # Alternative the standalone version
    #./run-csm.sh --app

&nbsp;

### Source code

You can edit ChordScaleMatrix for SuperCollider from the 
[ChordScaleMatrix](https://github.com/exesdotnet/ChordScaleMatrix) source-code.

&nbsp;

Feedback and Bug Reports
========================

Known issues are logged at [GitHub](https://github.com/exesdotnet/ChordScaleMatrix/issues).

If you experience problems or have questions pertaining to ChordScaleMatrix, please create an issue in the
[ChordScaleMatrix issue tracker](https://github.com/exesdotnet/ChordScaleMatrix/issues).

If you use the code for some project, please [let me know](mailto:thilo[at]exes.net).

&nbsp;

TO DO
-----

* Mode
    * Synchronize octaves in `Single note mode` and `Chord mode`
    
* Synthesizers
    * Debug and optimize the synths
    
* Song templates
    * Creating new song templates especially for chord progressions

* Preferences
    * Fix up checkbox value of `Windows in front`
    
* Standalone app
    * Preparing the files for a standalone application


List of Changes
---------------

Version 0.90

* New features:
    * Save documents to work on an edit

* Documentation Updates:
    * ...

* Issue fixes:
    * Fixed up chord mode
    * Fixed up midi preferences

Credits
=======

* [SuperCollider on Github](https://github.com/supercollider/supercollider)
* Fork of [Rukano's step sequencer](https://github.com/rukano/scprivatepool/tree/master/projects/midi_step_sequencer)

License
=======

ChordScaleMatrix is licensed under a Creative Commons Attribution-Share Alike 3.0 Unported [(CC BY-SA 3.0)](http://creativecommons.org/licenses/by-sa/3.0/) License.
Copyright Thilo Schneider, exes.net, 2017

Contributors
------------

0.90 beta
* Thilo Schneider

For more information please visit [exes.net](http://www.exes.net/) or send me an [e-mail](mailto:thilo[at]exes.net)!

&nbsp;
