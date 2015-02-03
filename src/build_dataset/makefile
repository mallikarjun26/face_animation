CC=g++
CFLAGS= -c -Wall
#CFLAGS= -std=c++11 -c -Wall
CINC=`pkg-config --cflags opencv`
LIBS=`pkg-config --libs opencv` -lboost_filesystem -lboost_system 

all: main 

main: main.o ExtractFaces.o FilterFaces.o BuildListOfSelectedFaces.o ExtractFrames.o 
	$(CC)  main.o ExtractFrames.o ExtractFaces.o FilterFaces.o BuildListOfSelectedFaces.o -o main $(LIBS)

ExtractFaces.o: ExtractFaces.cpp
	$(CC) $(CFLAGS) $(CINC) ExtractFaces.cpp

FilterFaces.o: FilterFaces.cpp
	$(CC) $(CFLAGS) $(CINC) FilterFaces.cpp

BuildListOfSelectedFaces.o: BuildListOfSelectedFaces.cpp
	$(CC) $(CFLAGS) $(CINC) BuildListOfSelectedFaces.cpp

ExtractFrames.o: ExtractFrames.cpp
	$(CC) $(CFLAGS) $(CINC) ExtractFrames.cpp

clean:
	rm -rf *o top 

