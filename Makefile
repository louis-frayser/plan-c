.PHONY: FORCE
DBTOP=files
default: README.md


help:
	@echo  make 'fix|clean'
	@echo where fix removes trailing blanks

Attic: FORCE
	@find . \( -name compiled -o -name db -o \
	          -name .git -o -name Attic \) -prune \
	   -o  -type d -print | while read dir ; do [ -d $$dir/Attic ] || \
	      mkdir -pv $$dir/Attic;done

clean:  Attic
	@find . -maxdepth 1 -name "*~" -exec mv -bv "{}" Attic/ \;
	@for a in $$(find . -name Attic) ;\
        do d=$${a%/*};\
	  for k in $$d/*~ $$d/#* $$d/.#*;\
	  do if test -e "$$k"; then  mv -v "$$k" $$d/Attic;fi ;\
	  done; \
	done
	@find ${DBTOP}/db \( -name Attic -prune \) \
	   -o -name "*~" -print |cpio -pvdm Attic
	@find ${DBTOP}/db -name "*~" -delete
	@echo CLEAN


install:
	chgrp wheel scripts
	chgrp +ws scripts
	mkdir -p ${DBTOP}/db
	chgrp wheel ${DBTOP}/db
	chmod g+ws ${DBTOP}/db
	@echo "See config and init scripts for /etc/{init,rc}.d in the scripts and config dirs"

clobber: clean
	@find . \( -name  Attic -o -name compiled \) -exec rm -f {}/* \;
	@echo CLOBBERED
	

fix:   FORCE
	@sh  scripts/cktrail.sh

clone-db:
	echo  "set search_path=plan_c;\
	       DELETE FROM assocs_dev; INSERT INTO assocs_dev (SELECT * FROM assocs);\
	       select setval('assocs_dev_id_seq',(select max(id) from assocs_dev));" |psql
