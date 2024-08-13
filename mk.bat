@echo off

echo Creating "begin" executable...
tools\vasm -nomsg=2050 -nomsg=2054 -nomsg=2052 -quiet -devpac -Fhunk -o src\begin.o src\begin.asm
if errorlevel 1 goto error
tools\vlink -S -s -o begin src\begin.o
if errorlevel 1 goto error
del src\begin.o

echo Creating "spy2" executable...
tools\vasm -nomsg=2050 -nomsg=2054 -nomsg=2052 -quiet -devpac -Fhunk -o src\spy2.o src\spy2.asm
if errorlevel 1 goto error
tools\vlink -S -s -o spy2 src\spy2.o
if errorlevel 1 goto error
del src\spy2.o

echo Done.
:error
