(
/*
https://github.com/exesdotnet/ChordScaleMatrix/
ChordScaleMatrix 0.91 beta
*/

//Server.default = s = Server.internal;
s.serverRunning.not.if({ s.boot });
//postf("\tDEBUG: %\n", "----------------");

s.waitForBoot({
	var screen, layout, window, t, kbwin, decorator, button, matrix, buttonMatrix, leds, chordsel;
	var synthName, scale, freqtune, octave, root, transp, sustain, amp;
	var font, fontsize, txtalign;
	var player, playButton, saveButton, control, controlView, sendType;
	var midiDevice, midiChannel;
	var synthList;
	var pointSize;
	var chordplayer, keyb;
	var chord, chords, chordnames, chordrix, gchordbtnsel, gchordsel, gMode;
	var menu, play;
	var fString, fundamental;
	var chordsym, chordstr;
	var numRows, numCols;
	var palettes, currentFile, datastr, issaved;
	var filedata, prefsx, fileprefs, chordInterChange, runCh;
	var ipos, midistr, midistrc, mstrc, degr;
	var aPrefStrs, aPrefStr, lfile, lfstr;
	var pan;

	GUI.qt;
	QtGUI.palette = QPalette.system;

	File.mkdir(File.getcwd++"/ChordScaleMatrix".standardizePath);

	prefsx = { arg prfs;
		var fr;
		var prfscale, prftuning, prfsynth, prfroot, prfoct, prftransp, prftempo, prfdur, prfamp, prfsend, prfmididev, prfmidich, prfmode, prftheme, prffront, prfdate;

		prfscale = control.chooseScale.value.asString;
		prftuning = control.chooseTuning.value.asString;
		prfsynth = control.chooseSynth.value.asString;
		prfroot = root.asString; prfoct = octave.asString;
		prftransp = transp.asString;
		prftempo = control.tempoSlide.value.asString;
		prfdur = sustain.asString; prfamp = amp.asString;
		prfsend = control.chooseSend.value.asString;
		prfmididev = control.chooseMidiDev.value.asString;
		prfmidich = control.chooseChan.value.asString;
		prfmode = control.chooseMode.value.asString;
		prftheme = control.chooseTheme.value.asString;
		prffront = control.cbFront.value.asString;
		prfdate = Date.getDate.format("%Y/%m/%d %H:%M:%S"); // %Y%m%d%H%M%S
		fr = prfscale++";"++prftuning++";"++prfsynth++";"++prfroot++";"++prfoct++";"++prftransp++";"++prftempo++";"++prfdur++";"++prfamp++";"++prfsend++";"++prfmididev++";"++prfmidich++";"++prfmode++";"++prftheme++";"++prffront++";"++prfdate;
		fr;
	};

	filedata = { arg mx, chmx, pref;
		var fresult;
		fresult = mx++";"++chmx++";"++pref++"";
		fresult;
	};

	fileprefs = { arg fileppath;
		var fpr;
		if (File.existsCaseSensitive(fileppath)) {
			f = File(fileppath, "r"); f.isOpen;
			t = SemiColonFileReader(f);
			aPrefStrs = t.read;
			f.close;
			aPrefStr = aPrefStrs[0];
			aPrefStr[0].postcs;
			aPrefStr[1].postcs;
			(2..17).do({ arg item; aPrefStr[item].postln });

			control.chooseScale.valueAction_(aPrefStr[2]);
			control.chooseTuning.valueAction_(aPrefStr[3]);
			control.chooseSynth.valueAction_(aPrefStr[4]);
			control.rootSlide.valueAction_(aPrefStr[5]);
			control.octSlide.valueAction_(aPrefStr[6]);
			control.transpSlide.valueAction_(aPrefStr[7]);
			control.tempoSlide.valueAction_(aPrefStr[8]);
			control.durSlide.valueAction_(aPrefStr[9]);
			control.ampSlide.valueAction_(aPrefStr[10]);
			control.chooseSend.valueAction_(aPrefStr[11]);
			aPrefStr[12].postcs;
			//control.chooseMidiDev.valueAction_(aPrefStr[12]);
			control.chooseChan.valueAction_(aPrefStr[13]);
			control.chooseMode.valueAction_(aPrefStr[14]);
			control.chooseTheme.valueAction_(aPrefStr[15]);
			//control.cbFront.valueAction_(aPrefStr[16].asCompileString.interpret);
			control.statusBar.string = " Last edited on "++aPrefStr[17];

			aPrefStr[0].asCompileString.postln;
			aPrefStr[0].interpret.colsDo{ |col, pos|
				col.do{ |item, i|
					buttonMatrix.at(i, pos).valueAction_(item.asInteger);
				}
			};

			aPrefStr[1].asCompileString.postln;
			aPrefStr[1].interpret.colsDo{ |col, pos|
				col.do{ |item, i|
					//postf("% %\n", item, i);
					chordrix.put(0, pos, item.asInteger);
				}
			}
		}{
			"File does not exist.".postln;
		};
		fpr;
	};

	numRows = 7*3;
	numCols = 2*16;
	screen = ();
	screen.width = Window.screenBounds.width;
	screen.height = Window.screenBounds.height;
	layout = ();
	pointSize = 20;
	synthList = [\ping, \glassharp, \hackbrett, \rlpf, \saw, \bass, \randomglitch];
	fundamental = 60;
	synthName = \ping;
	scale = nil;
	freqtune = 440;
	octave = 4;
	root = 0;
	transp = 0;
	sustain = 0.2;
	amp = 0.1;
	txtalign = \right;
	palettes = [QPalette.system, QPalette.light, QPalette.dark];
	currentFile = "";
	chords = [["Unison", [0]], ["Major", [0, 4, 7]], ["Minor", [0, 3, 7]],["5", [0, 7]], ["Dominant 7th", [0, 4, 7, 10]], ["Major 7th", [0, 4, 7, 11]], ["Minor 7th", [0, 3, 7, 10]], ["Minor Major 7th", [0, 3, 7, 11]], ["Sus 4", [0, 5, 7]], ["Sus 2",  [0, 2, 7]], ["6", [0, 4, 7, 9]], ["Minor 6", [0, 3, 7, 9]], ["9", [0, 2, 4, 7, 10]], ["Minor 9", [0, 2, 3, 7, 10]], ["Major 9", [0, 2, 4, 7, 11]], ["Minor Major 9", [0, 2, 3, 7, 11]], ["11", [0, 2, 4, 5, 7, 11]], ["Minor 11", [0, 2, 3, 5, 7, 10]], ["Major 11", [0, 2, 4, 5, 7, 11]], ["Minor Major 11", [0, 2, 3, 5, 7, 11]], ["13", [0, 2, 4, 7, 9, 10]], ["Minor 13", [0, 2, 3, 7, 9, 10]], ["Major 13", [0, 2, 4, 7, 9, 11]], ["Minor Major 13", [0, 2, 3, 7, 9, 11]], ["add 9", [0, 2, 4, 7]], ["Minor add 9", [0, 2, 3, 7]], ["6 add 9", [0, 2, 4, 7, 9]], ["Minor 6 add 9", [0, 2, 3, 7, 9]], ["Dominant 7th add 11", [0, 4, 5, 7, 10]], ["Major 7th add 11", [0, 4, 5, 7, 11]], ["Minor 7th add 11", [0, 3, 5, 7, 10]], ["Minor Major 7th add 11", [0, 3, 5, 7, 11]], ["Dominant 7th add 13", [0, 4, 7, 9, 10]], ["Major 7th add 13", [0, 4, 7, 9, 11]], ["Minor 7th add 13", [0, 3, 7, 9, 10]], ["Minor Major 7th add 13", [0, 3, 7, 9, 11]], ["7b5", [0, 4, 6, 10]], ["7#5", [0, 4, 8, 10]], ["7b9", [0, 1, 4, 7, 10]], ["7#9", [0, 3, 4, 7, 10]], ["7#5b9", [0, 1, 4, 8, 10]], ["m7b5", [0, 3, 6, 10]], ["m7#5", [0, 3, 8, 10]], ["m7b9", [0, 1, 3, 7, 10]], ["9#11", [0, 2, 4, 6, 7, 10]], ["9b13", [0, 2, 4, 7, 8, 10]], ["6sus4", [0, 5, 7, 9]], ["7sus4", [0, 5, 7, 10]], ["Major 7th Sus4", [0, 5, 7, 11]], ["9sus4", [0, 2, 5, 7, 10]], ["Major 9 Sus4", [0, 2, 5, 7, 11]]];
	chordnames = [];
	issaved = false;
	gMode = false;
	pan = -1.0.rand2;

	// layout stuff
	layout.width = numCols * pointSize;
	layout.height = numRows * pointSize;
	layout.centerPoint = ((screen.width/2) - (layout.width/2)@(screen.height/2) - (layout.height/2));
	layout.button = ((layout.width / numCols)@(layout.height / numRows));
	layout.center = Rect((screen.width - layout.width) / 2, screen.height,
		layout.width, layout.height + (layout.button.y + 10) + (layout.button.y + 10));

	// matrix window
	window = Window("Chord Scale Matrix - Notation", layout.center, resizable:false, border:true).front;
	window.userCanClose_(false);
	decorator = window.addFlowLayout(0@0, 0@0);

	// make arrays
	chordrix = Array2D.new(1, numCols);
	matrix = Array2D.new(numRows, numCols);
	buttonMatrix = Array2D.new(numRows, numCols);

	// make LEDs
	leds = numCols.collect{ |i|
		Button(window, Rect(0, 0, layout.button.x, layout.button.y))
		.states_([
			["", Color.black, Color.grey],
			["", Color.black, Color.green]
		])
		.enabled_(false)
	};

	StaticText(window, layout.width@10); // separator

	// make chord selection
	chordsel = numCols.collect{ |i|
		Button(window, Rect(0, 0, layout.button.x, layout.button.y))
		.states_([
			["", Color.black, Color.white],
			["", Color.white, Color.red]
		]).enabled_(false)
		.action_({ |v|
			if (v.value == 1) {
				chordsel.do({ arg item, isel;
					//[isel, item].postln;
					if (isel == i) {
						//runCh = true;
						gchordbtnsel = isel;
						chordInterChange.value(isel, nil);
					}{
						item.value_(0);
					};
				});
			}{
				chordInterChange.value(gchordbtnsel, nil);
			};
		});
	};

	// make chord buttons
	chordrix.postcs;
	chordrix.rowsDo{ |row, rowCount|
		row.do{ |item, i|
			//postf("% %\n", item, i);
			chordrix.put(rowCount, i, 0);
		};
	};

	StaticText(window, layout.width@10); // separator

	// make buttons
	buttonMatrix.rowsDo{ |row, rowCount|
		row.do{ |item, i|
			matrix.put(rowCount, i, 0);	// init matrix with 0s
			buttonMatrix.put(rowCount, i, Button(window, Rect(0, 0, layout.button.x, layout.button.y))
				.states_([
					["", Color.black, Color.white],
					["", Color.white, Color.black]
				])
				.action_({ |v|
					matrix.put(rowCount, i, v.value);
				});
			)
		};
	};

	// MIDI piano keyboard
	kbwin = ();
	kbwin.window = Window("Chord Scale Matrix - Piano Keyboard",
		Rect((screen.width - layout.width) / 2,
			((screen.height - layout.height) / 2) + 24,
			layout.width, 144)
	).front;
	kbwin.window.userCanClose_(false);

	keyb = MIDIKeyboard(kbwin.window, Rect(0, 0, layout.width, 120), 4, 48);

	keyb.keyDownAction_({arg note; fundamental = note;
		fString.string_(note.asString);
		keyb.showScale(chord, fundamental, Color.green);
	});

	keyb.keyTrackAction_({arg note; fundamental = note;
		fString.string_(note.asString);
		keyb.showScale(chord, fundamental, Color.green);
	});

	keyb.keyUpAction_({arg note; fundamental = note;
		fString.string_(note.asString);
		keyb.showScale(chord, fundamental, Color.green);
	});

	StaticText(kbwin.window, Rect(24, 120, 100, 24)).align_(\left).string_("Fundamental:");
	fString = StaticText(kbwin.window, Rect(124, 120, 100, 24)).align_(\left).string_(fundamental.asString);

	chords.do({arg item;
		//item[0].postln;
		chordnames = chordnames.add(item[0])
	});

	chord = chords[0][1];

	/*menu = PopUpMenu(kbwin.window, Rect(224, 160, 200, 24))
	.items_(chordnames)
	.action_({arg item;
	chord = chords[item.value][1];
	postf("%\n", chord);
	keyb.showScale(chord, fundamental, Color.green);
	play.focus;
	});

	play = Button(kbwin.window, Rect(424, 160, 120, 24))
	.states_([["Play"]])
	.action_({
	Task({
	/*chord.do({arg note;
	note = note + fundamental;
	Synth(\midikeyboardsine, [\freq, note.midicps]);
	0.4.wait;
	});
	0.4.wait;*/
	chord.do({arg note;
	note = note + fundamental;
	note.midicps.postln;
	Synth(\midikeyboardsine, [\freq, note.midicps, \amp, 0.1]);
	});
	}).start;
	});*/

	// player
	player = Task({
		inf.do{ |counter|
			var col = counter % numCols;

			matrix.colAt(col).do{ |item, pos|
				ipos = (pos - (numRows - 1)).abs;
				//if (chordrix.at(0, col).value.notNil) {
				if(gMode == true) {
					midistr = ipos.midinote.replace(" ", "").toUpper().replace("#", "s");
					chordstr = control.chooseChord.items[chordrix.at(0, col).value];
					midistrc = "'"++midistr++""++chordstr++"'.asDegrees("++scale++")"; // , 24
					mstrc = midistrc.interpret;
					//degr;
					//.keyToDegree(scale, 12)
					//degr = ipos + 12;
					degr = mstrc;
				}{
					degr = ipos;
					//octave = octave + 1;
				};
				//};
				//if (chordstr == "1") { degr = ipos; }{ degr = mstrc; };

				if(item != 0) {
					postf("% % %", ipos, degr, degr.midinote);
					//postf("% % % ", col, control.chooseChord.items[chordrix.at(0, col).value], chordrix.at(0, col).value);
					//midistr.postln();
					//midistrc.asCompileString.postln;
					//mstrc.postln();
					//ipos.cpsmidi.postln();
					//ipos.midicps.postln();
					//ipos.midiratio.postln();

					if(sendType == 0) {
						(instrument: synthName, scale: scale, amp: amp, sustain: sustain, octave: octave, root: root, ctranspose: transp, degree: degr).play;
					};
					if(sendType == 1) {
						(type: \midi, midiout: midiDevice, scale: scale, amp: amp, sustain: sustain, octave: octave, root: root, ctranspose: transp, degree: degr).play;
					};
					if(sendType == 2) {
						(instrument: synthName, scale: scale, amp: amp, sustain: sustain, octave: octave, root: root, ctranspose: transp, degree: degr).play;
						(type: \midi, midiout: midiDevice, scale: scale, amp: amp, sustain: sustain, octave: octave, root: root, ctranspose: transp, degree: degr).play;
					};
				};
			}; postf("\n----\n", "");

			// LED func
			if(col != 0){
				{
					leds[col].value_(1); // turn on actual
					leds[col-1].value_(0); // turn off last
				}.defer;

			}{
				{
					leds[col].value_(1);
					leds.last.value_(0);
				}.defer;
			};

			0.25.wait; // quarter notes
		}
	});

	// control window
	control = ();
	control.width = (screen.width - layout.width) / 2;
	control.height = layout.height + (layout.button.y + 10) + (layout.button.y + 10);

	control.window = Window("Chord Scale Matrix - Control", Rect(0, (screen.height - control.height - 22),
		control.width, control.height),
		resizable:false, border:true
	).front;
	control.window.userCanClose_(false);

	controlView = control.window.addFlowLayout(10@10, 10@4);

	control.button = ();
	control.button.width = 120;
	control.button.height = 24;
	control.button.dim = (control.button.width@control.button.height);

	t = TabbedView2.new(control.window, Rect(0, 0,
		control.width, control.height));

	t.add("Edit").flow({|w|

		StaticText(w, control.width@10); // separator

		// chord types
		StaticText(w, control.button.dim).string_("Chord type").align_(txtalign);
		control.chooseChord = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(ChordSymbol.shapes.keys.asArray.sort)
		.action_({ |menu|
			chordsym = ChordSymbol.shapes.at(menu.item);
			//postf("%\n", chordsym);
			keyb.clear; keyb.showScale(chordsym, fundamental, Color.green);
			chordstr = menu.item.asString;
			gchordsel = menu.value;
			if(runCh == true) { chordInterChange.value(nil, menu.value); };
		});
		control.chooseChord.valueAction_(0);
		control.chooseChord.enabled = false;
		keyb.clear;

		chordInterChange = { arg chordbtnsel, chordsel;
			var ret;
			postf("% %\n", chordbtnsel, chordsel);

			if(chordsel.isNil) {
				if(gchordsel.isNil) {
					chordsel = 0;
				}{
					chordsel = gchordsel;
				};
			};
			if(chordbtnsel.isNil) {
				if(gchordbtnsel.notNil) {
					chordbtnsel = gchordbtnsel;
					chordrix.put(0, chordbtnsel, chordsel);
				};
			}{
			};
			runCh = false;
			if(chordrix.at(0, chordbtnsel).value.notNil) {
				control.chooseChord.valueAction_(chordrix.at(0, chordbtnsel).value);
			}{
				control.chooseChord.valueAction_(0);
			};
			runCh = true;
			postf("%\n", chordrix);
			ret;
		};

		// mode
		StaticText(w, control.button.dim).string_("Mode").align_(txtalign);
		control.chooseMode = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(["Single note mode", "Chord mode"])
		.action_({ |menu|
			if(menu.value == 1){
				control.chooseChord.enabled = true;
				chordsel.do({ arg item; item.enabled = true; });
				//control.chooseChord.valueAction_(18);
				gMode = true;
			}{
				control.chooseChord.enabled = false;
				chordsel.do({ arg item; item.enabled = false; item.value_(0); });
				//control.chooseChord.valueAction_(0);
				gMode = false;
				keyb.clear;
			};
		}).toolTip_("Switch between single note and chord mode");
		control.chooseMode.valueAction_(0);

		StaticText(w, control.width@10); // separator

		// scale
		StaticText(w, control.button.dim).align_(txtalign).string_("Scale");
		control.chooseScale = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(ScaleInfo.scales.keys.asArray.sort)
		.action_({ |menu|
			scale = ScaleInfo.at(menu.item);
		});
		//control.chooseScale.valueAction_(0);
		control.chooseScale.valueAction_(11); // chromatic

		// tuning
		StaticText(w, control.button.dim).align_(txtalign).string_("Tuning");
		control.chooseTuning = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(TuningInfo.tunings.keys.asArray.sort)
		.action_({ |menu|
			scale.tuning_(menu.item);
		});
		//control.chooseTuning.valueAction_(0);
		control.chooseTuning.valueAction_(3); // et12

		StaticText(w, control.width@10); // separator

		// random scale
		Button(w, (control.width / 2) - 10@control.button.dim.y)
		.states_([["Random scale"]])
		.action_({
			control.chooseScale.valueAction_(
				control.chooseScale.items.indexOf(control.chooseScale.items.choose)
			);
		});

		// random tuning
		Button(w, (control.width / 2) - 20@control.button.dim.y)
		.states_([["Random tuning"]])
		.action_({
			control.chooseTuning.valueAction_(
				control.chooseTuning.items.indexOf(control.chooseTuning.items.choose)
			);
		});

		// random synth
		/*Button(control.window, (control.width / 2) - 10@control.button.dim.y)
		.states_([["Random synthesizer"]])
		.action_({
		control.chooseSynth.valueAction_(
		control.chooseSynth.items.indexOf(control.chooseSynth.items.choose)
		)
		});*/

		// random notes in matrix
		Button(w, (control.width / 2) - 10@control.button.dim.y)
		.states_([["Random notation"]])
		.action_({
			/*var rndb;
			if(control.chooseChord.enabled == true) {
			rndb = [1,0].choose;
			}{
			rndb = [1,0].wchoose([1,10].normalizeSum);
			};*/
			buttonMatrix.colsDo{ |col, pos|
				col.do{ |item, i|
					buttonMatrix.at(i, pos).valueAction_([1,0].wchoose([1,10].normalizeSum));
				}
			}
		}).toolTip_("Creates random notes in the matrtix window");

		// clear matrix
		Button(w, (control.width / 2) - 20@control.button.dim.y)
		.states_([["Clear matrix"]])
		.action_({
			buttonMatrix.colsDo{ |col, pos|
				col.do{ |item, i|
					buttonMatrix.at(i, pos).valueAction_(0);
				}
			};
			chordrix.colsDo{ |col, pos|
				col.do{ |item, i|
					postf("% %\n", item, i);
					chordrix.put(0, pos, 0);
				}
			}
		});

		StaticText(w, control.width@10); // separator


		// play / pause
		playButton = Button(w, (control.width / 2) - 10@control.button.dim.y)
		.states_([["Play"], ["Pause", Color.black, Color.green]])
		.action_({ |v|
			if(v.value == 1){
				player.play;
				//playButton.states_([["Play"], ["Pause", Color.black, Color.green]]);
			}{
				player.pause;
				//playButton.states_([["Play", Color.white, Color.gray], ["Pause", Color.black, Color.green]]);
			}
		});

		// stop
		Button(w, (control.width / 2) - 20@control.button.dim.y)
		.states_([["Stop"]])
		.action_({
			player.stop;
			player.reset;
			playButton.value_(0);
			leds.do{ |led| led.value_(0) };
		});

	});

	t.add("Synth / MIDI").flow({|w|

		StaticText(w, control.width@10); // separator

		// C / A hertz frequenz tuning
		/*StaticText(control.window, control.button.dim).align_(txtalign).string_("Frequence tuning");
		EZSlider(control.window, (control.width / 2)@control.button.dim.y,
		controlSpec: [1,1000, \linear, 1].asSpec, initVal: freqtune, numberWidth:36, gap:0@0)
		.action_({ |v|
		freqtune = v.value;
		});*/

		// root
		StaticText(w, control.button.dim).align_(txtalign).string_("Root note");
		control.rootSlide = EZSlider(w, (control.width / 2)@control.button.dim.y,
			controlSpec: [-12,24, \linear, 1].asSpec, initVal: root, numberWidth:36, gap:0@0)
		.action_({ |v|
			root = v.value;
		});

		// octave
		StaticText(w, control.button.dim).align_(txtalign).string_("Octave");
		control.octSlide = EZSlider(w, (control.width / 2)@control.button.dim.y,
			controlSpec: [1,8, \linear, 1].asSpec, initVal: octave, numberWidth:36, gap:0@0)
		.action_({ |v|
			octave = v.value;
		});

		// transpose
		StaticText(w, control.button.dim).align_(txtalign).string_("Transposing");
		control.transpSlide = EZSlider(w, (control.width / 2)@control.button.dim.y,
			controlSpec: [-24,24, \linear, 1].asSpec, initVal: transp, numberWidth:36, gap:0@0)
		.action_({ |v|
			transp = v.value;
		});

		// tempo
		StaticText(w, control.button.dim).align_(txtalign).string_("Tempo");
		control.tempoSlide = EZSlider(w,
			(control.width / 2)@control.button.dim.y,
			controlSpec: [1, 320, \linear, 0.1].asSpec, initVal: 60, numberWidth:36, gap:0@0)
		.action_({ |v|
			TempoClock.default.tempo_(v.value / 60);
		})
		.valueAction_(60);

		StaticText(w, control.width@10); // separator

		// synth
		StaticText(w, control.button.dim).align_(txtalign).string_("Synthesizer");
		control.chooseSynth = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(synthList)
		.action_({ |menu|
			synthName = menu.item;
		});

		// legato
		StaticText(w, control.button.dim).align_(txtalign).string_("Legato (duration)");
		control.durSlide = EZSlider(w, (control.width / 2)@control.button.dim.y,
			controlSpec: [0.001, 2, \linear, 0.01, 0.8].asSpec,
			initVal: 0.8, labelWidth: control.button.dim.x + 10, numberWidth:36, gap:0@0)
		.action_({ |v|
			sustain = v.value;
		})
		.valueAction_(0.8);

		// midi velocity
		StaticText(w, control.button.dim).string_("Note amplitude").align_(txtalign);
		control.ampSlide = EZSlider(w, (control.width / 2)@control.button.dim.y,
			numberWidth:36, gap: 0@0
		)
		.action_({ |v|
			amp = v.value;
		})
		.valueAction_(0.2);

		StaticText(w, control.width@10); // separator

		// send midi
		sendType = 0;
		StaticText(w, control.button.dim).string_("Send to").align_(txtalign);
		control.chooseSend = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(["SC synthesizer", "MIDI", "Both"])
		.action_({ |menu|
			sendType = menu.value;
			if(menu.value != 0){
				MIDIClient.init;
				control.chooseMidiDev.items_(
					MIDIClient.destinations.collect{ |aDevice|
						aDevice.name.asString
					}
				);
				midiDevice = MIDIOut(0);
			}{
				control.chooseMidiDev.items_(["Sending to SC only"]);
			};
		});

		// midi device
		midiDevice = nil;
		StaticText(w, control.button.dim).string_("MIDI device").align_(txtalign);
		control.chooseMidiDev = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(["Sending to SC only"])
		.action_({ |menu|
			midiDevice = MIDIOut(menu.value);
			postf("\tDEBUG: % -- %\n",
				MIDIClient.destinations[menu.value].device,
				MIDIClient.destinations[menu.value].name
			);
		});

		// midi channel
		midiChannel = 0;
		StaticText(w, control.button.dim).string_("MIDI channel").align_(txtalign);
		control.chooseChan = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_((0..15).collect{ |item| item.asString })
		.action_({ |menu|
			midiChannel = menu.value;
		});

		StaticText(w, control.width@10); // separator

	});

	t.add("Preferences").flow({|w|

		StaticText(w, control.width@10); // separator

		// font
		/*StaticText(control.window, control.button.dim).string_("Font").align_(txtalign);
		control.fonts = PopUpMenu(control.window, control.button.dim)
		.items_(Font.availableFonts); //[Font.defaultMonoFace, Font.defaultSansFace, Font.defaultSerifFace]
		//["Monospace"],["Sans serif"],["Serif"]

		StaticText(control.window, control.button.dim).string_("Size").align_(txtalign);
		control.fontsize = PopUpMenu(control.window, control.button.dim)
		.items_(["6","7","8","9","10","12","13","14","18","24","36","48","60","72","96"])
		.action_({ |v|
		/*var font;
		font = Font(y.items[y.value].asInteger);
		a.font_(font).refresh;*/
		});*/

		// GUI theme
		StaticText(w, control.button.dim).string_("GUI theme").align_(txtalign);
		control.chooseTheme = PopUpMenu(w, (control.width / 2)@control.button.dim.y)
		.items_(["System", "Light", "Dark"])
		.action_({ |menu|
			QtGUI.palette = palettes.at(menu.value);
		});
		control.chooseTheme.valueAction_(0);

		// window on top
		/*Button(control.window, (control.width - 20)@control.button.dim.y)
		.states_([["Windows always on top"], ["Flexible window state", Color.white, Color.grey]])
		.action_({ |v|
		if(v.value == 1){
		kbwin.window.alwaysOnTop_(true);
		control.window.alwaysOnTop_(true);
		window.alwaysOnTop_(true);
		}{
		kbwin.window.alwaysOnTop_(false);
		control.window.alwaysOnTop_(false);
		window.alwaysOnTop_(false);
		}
		});*/
		StaticText(w, control.button.dim).align_(txtalign).string_("Windows in front");
		control.cbFront = CheckBox(w, (control.width / 2)@control.button.dim.y)
		.action_({ |v|
			if(v.value == true){
				kbwin.window.alwaysOnTop_(true);
				control.window.alwaysOnTop_(true);
				window.alwaysOnTop_(true);
			}{
				kbwin.window.alwaysOnTop_(false);
				control.window.alwaysOnTop_(false);
				window.alwaysOnTop_(false);
			}
		});
	});

	t.add("File").flow({|w|

		StaticText(w, control.width@10); // separator

		// open file
		Button(w, (control.width / 2) - 10@control.button.dim.y)
		.states_([["Open file"]])
		.action_({ |v|
			Dialog.openPanel({ arg path;
				postf("% was opened.\n", path);
				if (File.existsCaseSensitive(path)) {
					f = File(path, "r"); f.isOpen;
					t = SemiColonFileReader(f);
					t.read.postcs;
					f.close;

					fileprefs.value(path);
					control.statusBar.string(" "++path++" loaded");
				}{
					"File does not exist.".postln;
				}

				},{
					"'Open file' cancelled".postln;
			}, multipleSelection: false);
		});

		// save as
		Button(w, (control.width / 2) - 20@control.button.dim.y)
		.states_([["Save file as"]])
		.action_({ |v|
			Dialog.savePanel({ arg path;
				var prefs = prefsx.value(nil);
				datastr = filedata.value(matrix.asCompileString, chordrix.asCompileString, prefs);

				//if (File.existsCaseSensitive(path)) {
				f = File(path, "w");
				f.write(datastr);
				f.close;
				//}{
				//	"File does not exist.".postln;
				//}
				postf("File was created in %.\n", path);
				currentFile = path;
				saveButton.enabled = true;

				issaved = true;
				},{
					"'Save file as' canceled".postln;
			});
		});

		// save
		saveButton = Button(w, (control.width / 2) - 10@control.button.dim.y)
		.states_([["Save file"]])
		.action_({
			if(currentFile.asString != "", {
				var prefs = prefsx.value(nil);
				datastr = filedata.value(matrix.asCompileString, chordrix.asCompileString, prefs);

				f = File(currentFile, "w");
				f.write(datastr);
				f.close;
				postf("File was created in %.\n", currentFile);

				issaved = true;
				},{
					"No file was specified.".postln;
			});
		});
		if(currentFile.asString == "", {
			saveButton.enabled = false;
		});

		// exit
		Button(w, (control.width / 2) - 20@control.button.dim.y)
		.states_([["Exit"]])
		.action_({
			var prefs = prefsx.value(nil);
			datastr = filedata.value(matrix.asCompileString, chordrix.asCompileString, prefs);

			f = File(File.getcwd++"/ChordScaleMatrix".standardizePath++"/main.csmx", "w");
			f.write(datastr);
			f.close;

			if (issaved == false) {
				f = File(File.getcwd++"/ChordScaleMatrix".standardizePath++"/lastfile.csmx.preferences", "w");
				f.write(File.getcwd++"/ChordScaleMatrix".standardizePath++"/main.csmx");
				f.close;
			}{
				f = File(File.getcwd++"/ChordScaleMatrix".standardizePath++"/lastfile.csmx.preferences", "w");
				f.write(File.getcwd++"/ChordScaleMatrix".standardizePath++"/"++currentFile);
				f.close;
			};

			player.stop; player.reset;
			window.close; control.window.close; kbwin.window.close;
			//s.volume.gui.close;

			/*// exit dialog
			var exitDialog = ();
			exitDialog.width = 320;
			exitDialog.height = 120;

			exitDialog = Window("Chord Scale Matrix - Exit Dialog", Rect(
			(screen.width - exitDialog.width) / 2,
			(screen.width - exitDialog.width) / 2,
			exitDialog.height, exitDialog.height),
			resizable:true, border:true
			).front;
			exitDialog.userCanClose_(true);
			exitDialog.alwaysOnTop_(true);

			Button(exitDialog, (control.width / 2) - 10@control.button.dim.y)
			.states_(["Cancel"])
			.action_({ |v|
			if(v.value == 1){

			}{

			}
			});
			Button(exitDialog, (control.width / 2) - 10@control.button.dim.y)
			.states_(["Exit"])
			.action_({ |v|
			if(v.value == 1){

			}{

			}
			});*/
		})
		.toolTip_("Attention! On exit file will be temporary saved in \n\""++File.getcwd++"/ChordScaleMatrix".standardizePath++"/main.csmx\".");

		StaticText(w, control.width@10); // separator

		// status bar
		control.statusBar = StaticText(w, (control.width - 20)@control.button.dim.y).align_(\left).string_(" ...")
		.background_(Color.gray)
		.stringColor_(Color.white);

	});

	lfile = File(File.getcwd++"/ChordScaleMatrix".standardizePath++"/lastfile.csmx.preferences", "r");
	lfstr = lfile.readAllString.stripWhiteSpace;
	lfile.close;
	fileprefs.value(lfstr);
	control.statusBar.string(" "++lfstr++" loaded");

	// synths

	// SINOSC
	/*SynthDef(synthList[0], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var sig = SinOsc.ar(freq, mul: 0.1);
	Out.ar(out, sig);
	}).add;

	// TRIANGLE WAVE
	SynthDef(synthList[1], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var sig = LFTri.ar(freq, mul: 0.1);
	Out.ar(out, sig);
	}).add;

	// SAWTOOTH WAVE
	SynthDef(synthList[2], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var sig = LFSaw.ar(freq, mul: 0.05);
	Out.ar(out, sig);
	}).add;

	// SQUARE WAVE
	SynthDef(synthList[3], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var sig = LFPulse.ar(freq, mul: 0.05);
	Out.ar(out, sig);
	}).add;

	// PULSE WAVE
	SynthDef(synthList[4], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var sig = LFPulse.ar(freq, width: 0.2, mul: 0.05);
	Out.ar(out, sig);
	}).add;*/

	// ping
	SynthDef(synthList[0], { |out, freq=440, pan, amp=0.1, sustain=0.25|
		var snd = SinOsc.ar(freq);
		snd = snd * EnvGen.ar(Env.perc(0.01, sustain), doneAction:2);
		snd = Pan2.ar(snd, pan);
		OffsetOut.ar(out, snd*amp);
	}).add;

	// sinus
	/*SynthDef(synthList[X], { |out, freq=440, pan, amp=0.1, sustain=0.25|
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.sine(sustain), doneAction:2);
	snd = Pan2.ar(snd, pan);
	OffsetOut.ar(out, snd*amp);
	}).add;*/

	// glassharp
	SynthDef(synthList[1], { |out, freq=440, pan, amp=0.1, sustain=0.25|
		var snd = SinOsc.ar(freq);
		snd = snd * EnvGen.ar(Env.perc(MouseX.kr(0,1)), doneAction:2);
		snd = Pan2.ar(snd, pan);
		OffsetOut.ar(out, snd*amp);
	}).add;

	// piano
	//TODO: Check if I have to translate midinote to freq
	/*SynthDef(synthList[X], {|midin, out=0|
	Out.ar(out, MdaPiano.ar(midin.midicps, decay:0.125)); // from sc3-plugins
	}).add;*/

	// hackbrett
	SynthDef(synthList[2], {arg amp = 0.1, freq = 440, decay = 5, dampen = 0.1;
		var env, snd;
		env = Env.linen(0, decay, 0).kr(doneAction: 2);
		snd = Pluck.ar(
			in: WhiteNoise.ar(amp),
			trig: Impulse.kr(0),
			maxdelaytime: 0.1,
			delaytime: freq.reciprocal,
			decaytime: decay,
			coef: dampen);
		Out.ar(0, [snd, snd]);
	}).add;

	// rlpf
	SynthDef(synthList[3], { arg out=0, amp=0.1, gate=1, pan=0, spread=0.8, freq=200, doneAction=2, ffreq=4000, rq=0.3;
		var sig, sig1, sig2, sig3;
		sig = LFSaw.ar(freq * [1.01,1,0.99]);
		sig = RLPF.ar(sig, ffreq, rq);
		sig = sig * EnvGen.ar(\adsr.kr(Env.adsr(0.01,0.1,0.8,0.1)),gate,doneAction:doneAction);
		sig = Splay.ar(sig, spread, amp, pan);
		Out.ar(out, sig);
	}).add;

	// sine
	/*SynthDef(synthList[X], { arg out=100, pan=0, trig=0.0, freq=500, amp=1, cutoff=10000, rezz=1;
	freq = Lag.kr(freq,0.1);
	Out.ar(out,Pan2.ar(RLPF.ar(Saw.ar([freq,freq*2],amp),cutoff,rezz),
	pan));
	}).add;*/

	// saw
	SynthDef(synthList[4],{ arg out=100, pan=0, sustain=0.5, freq=500, amp=1, cutoff=10000, rezz=1;
		var env;
		env = EnvGen.kr(Env.perc(0.01, sustain, 0.2), doneAction:0, gate:amp);
		Out.ar(out,Pan2.ar(RLPF.ar(Saw.ar(Lag.kr(freq,0.1),env),cutoff,rezz)*amp,
			pan));
	}).add;

	// envsaw
	/*SynthDef(synthList[X], { arg out, freq = 1000, gate = 1, pan = 0, cut = 4000, rez = 0.8, amp = 1;
	Out.ar(out,
	Pan2.ar(
	RLPF.ar(
	Pulse.ar(freq,0.05),
	cut, rez),
	pan) * EnvGen.kr(Env.linen(0.01, 1, 0.3), gate, amp, doneAction:2);
	)
	}).add;*/

	// patter
	/*SynthDef(synthList[X], { arg out, freq = 1000, gate = 1, pan = 0, cut = 4000, rez = 0.8, amp = 1;
	Out.ar(out,
	Pan2.ar(
	RLPF.ar(
	SinOsc.ar(freq,0.05),
	cut, rez),
	pan) * EnvGen.kr(Env.linen(0.01, 1, 0.3), gate, amp, doneAction:2);
	)
	}).add;*/

	// bass(_Ex)
	SynthDef(synthList[5], { |freq = 440, gate = 1, amp = 0.5, slideTime = 0.17, ffreq = 1100, width = 0.15,
		detune = 1.005, preamp = 4|
		var    sig,
		env = Env.adsr(0.01, 0.3, 0.4, 0.1);
		freq = Lag.kr(freq, slideTime);
		sig = Mix(VarSaw.ar([freq, freq * detune], 0, width, preamp)).distort * amp
		* EnvGen.kr(env, gate, doneAction: 2);
		sig = LPF.ar(sig, ffreq);
		Out.ar(0, sig ! 2)
	}).add;

	// smooth
	/*SynthDef(synthList[X], { |freq = 440, sustain = 1, amp = 0.5|
	var sig;
	sig = SinOsc.ar(freq, 0, amp) * EnvGen.kr(Env.linen(0.05, sustain, 0.1), doneAction: 2);
	Out.ar(0, sig ! 2)
	}).add;*/

	// randomglitch
	SynthDef(synthList[6], { |index = 0, amp = 1, stretch = 1, pan = 0| // args: horizontal position in grid, amplitude and stretch correction, pan
		var sig = Pan2.ar( // tweak sig to get different sound texture
			PMOsc.ar(80.exprand(10000), 1.exprand(200), 1.exprand(20)),
			pan,
			EnvGen.kr(Env(Array.rand(4, 0, 0.05.rrand(0.4)).add(0), Array.rand(3, 0.1, 1.2).add(0.1), 5.rand2), levelScale: amp, timeScale: stretch, doneAction: 2)
		);
		Out.ar(0, sig);
	}).add;

	// peep
	/*SynthDef(synthList[X],{|freq=100|
	var snd = SinOsc.ar(freq);
	snd = snd * EnvGen.ar(Env.perc(0.001,0.25), doneAction:2);
	Out.ar(0, snd ! 2);
	}).add;*/

	// rstp
	/*SynthDef(synthList[X], {
	var sig = Pan2.ar(
	PMOsc.ar(80.exprand(10000), 1.exprand(200), 1.exprand(20)),
	-1.0.rand2,
	EnvGen.kr(Env(Array.rand(4, 0, 0.1.rrand(0.5)).add(0), Array.rand(3, 0.1, 0.3).add(0.1), -5.rrand(5)), doneAction: 2)
	);
	Out.ar(0, sig);
	}).add;*/
});
)

// debugging
(
//s.volume.gui;
/*v = s.volume;
v.min;
v.max;
v.volume = rrand(-50, 5);
v.setVolumeRange(-90, 8);
v.mute;
v.unmute;
// separate window
v.gui;*/

//Scale.directory;
//Tuning.directory;

// Exports a CSV list for debugging
var cnote = "C";
var ns = ""; var nsn = "";
var strdata = "C note;Notes;Scale;Degrees;MIDI notes\n";
ChordSymbol.shapes.keys.asArray.sort.do{ arg item;
	ScaleInfo.scales.keys.asArray.sort.do{ arg si;
		strdata = strdata++cnote++""++item++";";
		nsn = "'"++cnote++""++item++"'.asNotes;";
		strdata = strdata++""++nsn.interpret++";"++si++";";
		ns = "'"++cnote++""++item++"'.asDegrees("++ScaleInfo.at(si)++")";
		strdata = strdata++""++ns.interpret++";";
		strdata = strdata++""++ns.interpret.midinote++"\n";
	};
};
f = File(File.getcwd++"/ChordScaleMatrix".standardizePath++"/CChordsScalesDegreesMidi.csv", "w");
f.write(strdata);
f.close;
)