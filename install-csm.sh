#!/bin/bash

if [ $# -ge 2 ]; then
	echo ""
	echo "Usage: $0 OPTIONS"
	echo "--git : Clone the git repository"
	echo ""
	exit 1
fi

sudo apt-get install -y subversion # Is required for SuperCollider 3.6.6 Quarks download
sudo add-apt-repository ppa:git-core/ppa # Is required for SuperCollider 3.9 Quarks download
sudo apt-get update
sudo apt-get install -y git
sudo apt-get install -y supercollider supercollider-ide sc3-plugins sc3-plugins-language

if [ "$1" = "--git" ]; then

	if [ ! -d ~/ChordScaleMatrix ]; then mkdir ~/ChordScaleMatrix; fi

	cd ~/Downloads

	# [ ChordScaleMatrix ]
	git clone https://github.com/exesdotnet/ChordScaleMatrix.git
	
	mv ~/Downloads/ChordScaleMatrix/* ~/ChordScaleMatrix

	# Install as SuperCollider extension, ref http://doc.sccode.org/Guides/UsingExtensions.html

	# On Linux
	mkdir -p ~/.local/share/SuperCollider/Extensions || true
	# On Mac OSX
	#mkdir -p "$HOME/Library/Application Support/SuperCollider/Extensions" || true

	# [ ChordSymbol ]
	git clone https://github.com/triss/ChordSymbol.git
	cd ~/Downloads/ChordSymbol
	# On Linux
	ln -s `pwd` ~/.local/share/SuperCollider/Extensions/ChordSymbol
	# On Mac OSX
	#ln -s `pwd` "$HOME/Library/Application Support/SuperCollider/Extensions/ChordSymbol"

	# [ modfm-synth ]
	git clone https://github.com/filib/modfm-synth.git
	cd ~/Downloads/modfm-synth
	# On Linux
	ln -s `pwd` ~/.local/share/SuperCollider/Extensions/modfm-synth
	# On Mac OSX
	#ln -s `pwd` "$HOME/Library/Application Support/SuperCollider/Extensions/modfm-synth"

	mv synthesizer.sc synthesizer.sc.bak

	cd ~

else

	wget https://github.com/triss/ChordSymbol/archive/master.zip -O ~/Downloads/ChordSymbol.zip
	unzip ~/Downloads/ChordSymbol.zip -d ~/Downloads/ChordSymbol
	mv ~/Downloads/ChordSymbol ~/.local/share/SuperCollider/Extensions

	wget https://github.com/filib/modfm-synth/archive/master.zip -O ~/Downloads/modfm-synth.zip
	unzip ~/Downloads/modfm-synth.zip -d ~/Downloads/modfm-synth
	mv ~/Downloads/modfm-synth ~/.local/share/SuperCollider/Extensions
	mv ~/.local/share/SuperCollider/Extensions/synthesizer.sc ~/.local/share/SuperCollider/Extensions/synthesizer.sc.bak

	#(firefox https://github.com/exesdotnet/ChordScaleMatrix/ &> /dev/null &)
	wget https://github.com/exesdotnet/ChordScaleMatrix/archive/master.zip -O ~/Downloads/ChordScaleMatrix.zip
	unzip ~/Downloads/ChordScaleMatrix.zip -d ~/Downloads/ChordScaleMatrix

	sudo mkdir /opt/ChordScaleMatrix
	sudo chown -R $USER:$USER /opt/ChordScaleMatrix
	mv /home/$USER/Downloads/ChordScaleMatrix/* /opt/ChordScaleMatrix
	chmod ugo+x /opt/ChordScaleMatrix/install-csm.sh /opt/ChordScaleMatrix/run-csm.sh
	rm -R /home/$USER/Downloads/ChordScaleMatrix

	echo "[Desktop Entry]
Version=1.0
Type=Application
Name=ChordScaleMatrix
Icon=application-x-executable
Exec=/opt/ChordScaleMatrix/run-csm.sh
Comment=Chord Scale Matrix
Categories=Audio;AudioVideo;Music;
Terminal=false
MimeType=application/x-chordscalematrix
" > ~/.local/share/applications/chordscalematrix.desktop

	echo ""
	echo "Do you like to start ChordScaleMatrix now? [ y | n ]"
	read yorn
	if [ "$yorn" = "y" ]; then
		(/opt/ChordScaleMatrix/run-csm.sh &> /dev/null &)
	fi

fi

