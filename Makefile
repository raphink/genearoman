FONTSDIR := fonts
# screen, ebook, prepress, printer, default
QUALITY := printer
# Impression sur papier a3, 156*2=312mm
BOOKLET_PAPER := {234mm,312mm}
HTML_THEME_DIR := pandoc-bootstrap-adaptive-template

all: docs

booklet: long_tom-book.pdf

docs: docs/index.html long_tom.pdf
	cp long_tom.pdf docs/
	git commit -m "Update docs" docs/

stats:
	find chapitres/ -name "*.md" -not -name '00_titre.md' -print0 | sort -z | xargs -0 wc -w


%.md:
	cat meta.md > $@
	find chapitres/ -name "*.md"  -print0 | sort -z | xargs -0 cat >> $@

%.tex: %.md
	pandoc --pdf-engine lualatex  --template extended.tex \
		   --variable numbersections --toc --variable toc-depth=2 \
		   --variable documentclass=memoir --variable fontsize=12pt \
		   --filter pandoc-citeproc \
		   --verbose \
		   $< -o $@

%_annexes.tex: %.md
	pandoc --pdf-engine lualatex  --template extended.tex \
		   --variable numbersections --toc --variable toc-depth=2 \
		   --variable documentclass=memoir --variable fontsize=12pt \
		   --filter pandoc-citeproc \
		   --verbose \
		   $< annexes.md -o $@

%.pdf: %.tex
	OSFONTDIR=$(FONTSDIR) lualatex $<

%-book.pdf: %.pdf
    #
	pdfbook --papersize '$(BOOKLET_PAPER)' $<

%_$(QUALITY).pdf: %.pdf
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer -dNOPAUSE -dBATCH  -dQUIET -sOutputFile="$@" "$<"

%.html: %.md
	pandoc --verbose $< -o $@ --template $(HTML_THEME_DIR)/standalone.html --css $(HTML_THEME_DIR)/template.css

%.epub: %.md
	pandoc --verbose $< -o $@

clean:
	rm -f *.log *.aux *.ilg *.ind *.idx *.out *.toc *.pdf *.lof *.tex

.PHONY: clean

