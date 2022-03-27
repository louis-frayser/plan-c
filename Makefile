default:

Attic:
	mkdir Attic

clean:  Attic 
	find . -maxdepth 1 -name "*~" -exec mv -b "{}" Attic/ \;
