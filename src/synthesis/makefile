C=g++
CFLAGS = `pkg-config --cflags opencv`
LIBS = `pkg-config --libs opencv`

all: top

top: main.o constructGraph.o travelDijkstra.o 
	$(CC) $(CFLAGS) main.o ConstructGraph.o TravelDijkstra.o

main.o: main.cpp
	$(CC) $(CFLAGS) main.cpp

constructGraph.o: ConstructGraph.cpp
	$(CC) $(CFLAGS) ConstructGraph.cpp

travelDijkstra.o: TravelDijkstra.cpp
	$(CC) $(CFLAGS) TravelDijkstra.cpp
