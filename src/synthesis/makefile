CC=g++
CFLAGS= -c -Wall
CINC=`pkg-config --cflags opencv`
LIBS=`pkg-config --libs opencv`

all: main 

main: main.o ConstructGraph.o TraversalDijkstra.o 
	$(CC)  main.o ConstructGraph.o TraversalDijkstra.o -o main $(LIBS)

main.o: main.cpp
	$(CC) $(CFLAGS) main.cpp

ConstructGraph.o: ConstructGraph.cpp
	$(CC) $(CFLAGS) $(CINC) ConstructGraph.cpp

TraversalDijkstra.o: TraversalDijkstra.cpp
	$(CC) $(CFLAGS) $(CINC) TraversalDijkstra.cpp

clean:
	rm -rf *o top 

