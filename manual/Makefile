all: realimentados.pdf

clean:
	$(RM) *~ *.pdf *.dvi *.log *.aux *.bbl *.blg *.toc *.lol *.loa *.lox \
		*.lot *.out *.lg *.tmp *.xref *.lof .*.swp *.idx *.ilg *.ind *.ist

realimentados.pdf: realimentados.tex
	pdflatex realimentados
	#bibtex realimentados
	pdflatex realimentados
	pdflatex realimentados
	mv realimentados.pdf ./pdf/
