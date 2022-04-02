default:

Attic:
	mkdir Attic

clean:  Attic 
	@find . -maxdepth 1 -name "*~" -exec mv -bv "{}" Attic/ \;
	@for a in $$(find . -name Attic) ;\
        do d=$${a%/*};\
	  for k in $$d/*~ ;\
	  do test -e $$k && mv -v $$d/*~ $$d/Attic ;\
	     break; \
	  done; \
	done
	@echo CLEAN

clobber: clean
	@rm -frv compiled
	@echo CLOBBER
