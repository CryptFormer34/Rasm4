#!/bin/bash

set -e

test -d ./obj/ || mkdir ./obj/
test -f ./obj/functions.o && rm ./obj/functions.o

as -g -o ./obj/functions.o ./src/*.s
ld -o rasm4 ./obj/functions.o /usr/lib/aarch64-linux-gnu/libc.so -dynamic-linker /lib/ld-linux-aarch64.so.1 ../obj/*
#ld -o rasm4 ./obj/functions.o /usr/lib/aarch64-linux-gnu/libc.so -dynamic-linker /lib/ld-linux-aarch64.so.1 ../obj/int64asc.o ../obj/putch.o ../obj/putstring.o ../obj/getstring.o


rm -rf ./obj/

./rasm4

# sudo chmod +x build
# ./build

# valgrind --leak-check=full --show-leak-kinds=all --track-origins=yes -s ./rasm4