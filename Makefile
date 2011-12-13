CC=gcc
LOPT=-lpthread -llua5.1 -lallegro -lallegro_primitives -Wall

all:
	$(CC) $(LOPT) *.c -o transport

clean:
	rm transport
