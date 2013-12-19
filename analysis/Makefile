TEXFILE = report.tex
TEXDIR = ./tex/
OUTPUT = report.pdf

all: attachments.tar.gz code.tar.gz
	pdflatex --shell-escape $(TEXDIR)$(TEXFILE)
	pdflatex --shell-escape $(TEXDIR)$(TEXFILE)
	pdflatex --shell-escape $(TEXDIR)$(TEXFILE)
	make clean
	wc $(TEXDIR)*.tex

clean:
	for FILE in `find . -type f | grep -e "\.pyg\|\.aux\|\.log\|\.toc\|\.out\|\.equ\|\.lof\|\.tar\.gz"`; do rm $$FILE; done

attachments.tar.gz:
	tar -zcf attachments.tar.gz $(TEXDIR)*.tex code
	mv attachments.tar.gz $(TEXDIR)

code.tar.gz:
	tar -czf code.tar.gz ./code/*.py ./code/*.R ./code/*.txt ./code/*.csv
	mv code.tar.gz $(TEXDIR)

push:
	scp $(OUTPUT) root@will-farmer.com:/var/www
