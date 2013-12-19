TEXFILE = ProjectProposal.tex
TEXDIR = ./tex/
OUTPUT = ProjectProposal.pdf

all:
	pdflatex --shell-escape $(TEXDIR)$(TEXFILE)
	pdflatex --shell-escape $(TEXDIR)$(TEXFILE)
	pdflatex --shell-escape $(TEXDIR)$(TEXFILE)
	make clean

clean:
	for FILE in `find . -type f | grep -e "\.pyg\|\.aux\|\.log\|\.toc\|\.out\|\.equ\|\.lof\|\.tar\.gz"`; do rm $$FILE; done
