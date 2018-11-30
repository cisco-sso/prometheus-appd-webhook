BIN := ~/plantuml/plantuml.jar
MD  := ./README.md

pdf: refresh
	markdown-pdf ${MD}

refresh: ${BIN}
	-rm -Rf *.png
	java -jar ${BIN} *.puml

download: ${BIN}
	-mkdir ~/plantuml
	wget -O ${BIN} http://sourceforge.net/projects/plantuml/files/plantuml.jar/download 


install: download
	brew cask install java
	brew install libtool
	brew install graphviz
	npm install -g markdown-pdf

clean:
	-rm -Rf *~

clean-all: clean
	-rm -Rf *.png
