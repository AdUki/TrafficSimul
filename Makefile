# compiler
CC=gcc

# suffix for your libraries, i am using version 5.0.7 dynamic linked
LIB_SUFFIX=-5.0.7-md

# linker options
LOPT=-lpthread -llua -lallegro$(LIB_SUFFIX) -lallegro_primitives$(LIB_SUFFIX) -Wall

all:
	$(CC) *.c -o transport $(LOPT) 

clean:
	rm transport*
