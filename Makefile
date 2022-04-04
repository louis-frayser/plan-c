default:

Attic:
	mkdir Attic

clean:  Attic 
	@find . -maxdepth 1 -name "*~" -exec mv -bv "{}" Attic/ \;
	@for a in $$(find . -name Attic) ;\
        do d=$${a%/*};\
	  for k in $$d/*~ $$d/#* $$d/.#*;\
	  do if test -e "$$k"; then  mv -v "$$k" $$d/Attic;fi ;\
	  done; \
	done
	@find lib/db \( -name Attic -prune \) \
	   -o -name "*~" -print |cpio -pvdm Attic
	@find lib/db -name "*~" -delete
	@echo CLEAN

clobber: clean
	@rm -frv compiled
	@echo CLOBBER
