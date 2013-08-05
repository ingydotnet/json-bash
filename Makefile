.PHONY: default help doc test \
    install install-lib install-doc \
    uninstall uninstall-lib uninstall-doc \

CMD=json.bash

# XXX Add submodule checker

##
# User facing rules start here:
default: help

help:
	@echo 'Makefile rules:'
	@echo ''
	@echo 'test       Run all tests'
	@echo 'install    Install $(CMD)'
	@echo 'uninstall  Uninstall $(CMD)'
	@echo 'clean      Remove build/test files'

doc: doc/$(CMD).1

test:
	prove $(PROVE_OPTIONS) test/

install: install-lib install-doc

install-lib: $(INSTALL_LIB)
	install -m 0755 lib/$(CMD) $(INSTALL_LIB)/

install-doc: doc
	install -c -d -m 0755 $(MAN1DIR)
	install -c -m 0644 doc/$(CMD).1 $(MAN1DIR)

uninstall: uninstall-lib uninstall-doc

uninstall-lib:
	rm -f $(INSTALL_LIB)/$(CMD)

uninstall-doc:
	rm -f $(MAN1DIR)/$(CMD).1

clean purge:
	true

##
# Builder rules:
$(CMD).txt: $(CMD).asc
	cp $< $@

%.xml: %.txt
	asciidoc -b docbook -d manpage -f doc/asciidoc.conf
	rm $<

%.1: %.xml
	xmlto -m doc/manpage-normal.xsl man $^

doc/%.1: %.1
	mv $< $@
