CPP=clang++
CPPFLAGS=-Wall -Wextra -Werror
CPPFLAGS+=-std=c++11
CPPFLAGS+=-ggdb3
CPPFLAGS+=-O0

LDFLAGS=-lgif -lcrypto
OBJS=teletekst.o tools.o tt_wrapper.o

all: $(OBJS) foo

%.o: %.cpp
	$(CPP) -c $(CPPFLAGS) $^

foo: test.o $(OBJS)
	$(CPP) $(CPPFLAGS) -o $@ $^ $(LDFLAGS)

.PHONY: clean
clean:
	-rm -f foo
	-rm -f core
	-rm -f $(OBJS)
