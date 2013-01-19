.PHONY: all clean suite

CFLAGS=-std=c99 -Wall -Werror -fobjc-arc -framework Foundation 
CFLAGS+=-I/usr/include/libxml2/ -Ivendor/DTHTMLParser

LDLIBS=-lxml2

all: suite

clean:
	rm -f test actual.txt *.o

suite: test
	@./test >actual.txt
	diff expected.txt actual.txt
	@rm -f actual.txt	

test: test.m BBUHTMLParser.m vendor/DTHTMLParser/DTHTMLParser.m
