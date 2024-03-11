.POSIX:
.SUFFIXES:
.PHONY: \
	check \
	install \
	uninstall

check:
	sunder-test

install:
	mkdir -p "$(SUNDER_HOME)/lib/bubby"
	cp bubby.sunder "$(SUNDER_HOME)/lib/bubby"

uninstall:
	rm -rf "$(SUNDER_HOME)/lib/bubby"
