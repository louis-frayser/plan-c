default:

Attic:
	mkdir Attic

clean:  Attic 
	find . -maxdepth 1 -name "*~" -exec mv -b "{}" Attic/ \;
	for a in $$(find . -name Attic) ;\
        do d=$${a%/*};\
	  for k in $$d/*~ ;\
	  do test -e $$k && mv $$d/*~ $$d/Attic ;\
	     break; \
	  done; \
	done
