MATLABPATH=/scratch/applis/x86_64/matlab2013a

MEX=$(MATLABPATH)/bin/mex
MEXEXT=mexa64
CC=gcc

FILES=kendalltau.c

CFLAGS=-W -Wall -I$(MATLABPATH)/extern/include -fPIC -fopenmp -DOMP
LDFLAGS=-lm -lgomp -lpthread -fopenmp

MEXFLAGS=-largeArrayDims

.SUFFIXES : .c .o .so .$(MEXEXT)

all:	kendalltau.$(MEXEXT) kendalltau_test

kendalltau_test: $(FILES)
	$(CC) -g $(CFLAGS) $(LDFLAGS) -o kendalltau_test $(FILES)

kendalltau.$(MEXEXT): $(FILES)
	$(CC) $(CFLAGS) -DMATLAB_MEX_FILE -c kendalltau.c -o kendalltau.o
	$(MEX) -cxx $(MEXFLAGS) LDFLAGS="$(LDFLAGS) -shared" kendalltau.o -output kendalltau.$(MEXEXT)

clean:
	rm -f *.o *~ $(DST)

distclean: clean
	rm -f kendalltau.$(MEXEXT) kendalltau_test
