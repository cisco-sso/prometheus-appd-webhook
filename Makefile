.DEFAULT_GOAL = all

# Base Variables

PUML_JAR := tmp/plantuml.jar
PUML_JAR_URL := https://sourceforge.net/projects/plantuml/files/plantuml.jar/download

## Soure Variables

SRC_MD = $(wildcard *.md) $(wildcard docs/*.md)
PDF_MD = $(SRC_MD:.md=.pdf)

SRC_PUML = $(wildcard docs/*.puml)
PNG_PUML = $(SRC_PUML:.puml=.png)

## Phony Targets

.PHONY: all
all: docs

.PHONY: clean
clean:
	rm -rf ./tmp
	rm -f $(PNG_PUML) $(PDF_MD)

.PHONY: docs
docs: $(PNG_PUML) $(PDF_MD)  # Render images before PDFs.

.PHONY: install
install: ${PUML_JAR}
	brew cask install java
	brew install graphviz libtool node
	npm install -g markdown-pdf

## Real Targets

%.pdf: %.md $(PNG_PUML)
	## The word parse is to gracefully ignore filenames that are
	## transient dependencies.
	markdown-pdf -o $@ $(word 1, $<)

docs/%.pdf: docs/%.md $(PNG_PUML)
	## We must cd into this directory because images embedded
	## in markdown files use relative links.
	##
	## The word parse is to gracefully ignore filenames that are
	## transient dependencies.
	cd docs && markdown-pdf -o $(notdir $@) $(notdir $(word 1, $<))

docs/%.png: docs/%.puml
	java -jar ${PUML_JAR} $<

tmp:
	mkdir -p tmp

${PUML_JAR}: tmp
	curl -fsSL -o $@ ${PUML_JAR_URL}
