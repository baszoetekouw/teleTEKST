
foo: teletekst.cpp
	g++ -std=c++11 -ggdb3 -O0 -o $@ $^ -lgif

.PHONY: clean
clean:
	-rm -f foo
	-rm -f core
