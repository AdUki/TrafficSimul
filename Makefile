CC=gcc

# suffix for your libraries, i am using version 5.0.7 dynamic linked
PLATFORM=win32
LIB_SUFFIX=-5.0.7-md

# linker options
LOPT= -llua -lallegro$(LIB_SUFFIX) -lallegro_primitives$(LIB_SUFFIX) -Wall

all:
	luac -o $(PLATFORM)/engine.luac lua/arrive.lua lua/behavior.lua lua/init.lua lua/car.lua
	$(CC) -L$(PLATFORM)/lib -Iinclude src/*.c -o $(PLATFORM)/transport $(LOPT) 

clean:
	rm $(PLATFORM)/transport*
	rm $(PLATFORM)/engine.luac
