build/pdfpop: pdfpop.m
	mkdir -p $(@D)
	clang pdfpop.m -fmodules -mmacosx-version-min=10.4 -o build/pdfpop
