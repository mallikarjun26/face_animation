CC=g++
CFLAGS= -c

all: EdgeWeightTransform.o graph_statistics.o
	$(CC) EdgeWeightTransform.o graph_statistics.o -o EdgeWeightTransform

EdgeWeightTransform.o: EdgeWeightTransform.cpp
	$(CC) $(CFLAGS) EdgeWeightTransform.cpp -o EdgeWeightTransform.o 

graph_statistics.o: graph_statistics.cpp
	$(CC) $(CFLAGS) graph_statistics.cpp -o graph_statistics.o 

clean:
	rm -rf *o top 

