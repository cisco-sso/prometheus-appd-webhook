BIN     := ~/plantuml/plantuml.jar
MD      := ./README.md
PNG_SRC := block-diagram.md sequence.md

pdf: refresh
	markdown-pdf ${MD}

refresh: ${BIN}
	-rm -Rf *.png *.puml
	$(foreach file,${PNG_SRC},sed -e '$$ d' $(file) | sed -e '1d' > $(file).puml;)
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
