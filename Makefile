CPP=clang++
CPPFLAGS=-Wall -Wextra -Werror
CPPFLAGS+=-std=c++11
#CPPFLAGS+=-ggdb3
CPPFLAGS+=-O3


foo: teletekst.cpp
	$(CPP) $(CPPFLAGS) -o $@ $^ -lgif -lcrypto

.PHONY: clean
clean:
	-rm -f foo
	-rm -f core
