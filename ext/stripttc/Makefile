# stripttc.c originates from:
# https://github.com/fontforge/fontforge/blob/master/contrib/fonttools/stripttc.c

default: stripttc.so

stripttc.so: stripttc.o
	gcc -shared -o $@ $<

stripttc.o: stripttc.c
	gcc -c -fPIC -o $@ $<

install:
	: # do nothing, we'll load the lib directly

clean:
	-rm *.so *.o
