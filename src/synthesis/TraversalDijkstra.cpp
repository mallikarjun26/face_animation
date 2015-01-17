//============================================================================
// Name        : DijkstraAlgorithm.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <fstream>
#include <queue>
#include <list>
#include <set>
#include <limits>
#include <map>
#include "Node.hpp"

//#include <boost>

using namespace std;
//using namespace boost;

struct ComparePair {
	bool operator() (const Node &a, const Node &b ) const {
		long double t1 = a.distance;
		long double t2 = b.distance;
 		return t1 > t2;
	}
};

/*	Node temp(3,1214);
	Q.push(temp);
	temp.set(1,23245);
	Q.push(temp);
	temp.set(2,2);
	Q.push(temp);

	while(!Q.empty()) {
		Node temp = Q.top();
		Q.pop();
		cout << "Node:" << temp.id << " Weight:" << temp.distance << endl;
	}
*/

/*	adjacencyList[0].push_back(make_pair(1,232));
    cout << "Debug 00:: *(adjacencyList[0].begin).first: " << (*adjacencyList[0].begin()).first << endl;
*/

void traversalDijkstra(int numberOfNodes, int src, int dst, map< int, list < pair<int, long double> > > adjacencyList, list<int> &traverseList, const string outputLocation) {

	set< pair<long double,int> >                             Q;
	vector< long double >                                    d(numberOfNodes);
	list< pair<int, long double> >                           S;                           // pair<node, minDistance>

	vector< list<int> > shortestPaths(numberOfNodes);
	int prevFixedNodeList[numberOfNodes];


    cout << "numberOfNodes=" << numberOfNodes << " src=" << src << " dst=" << dst << endl; 

	// Distance of all nodes from source
	for(int i=0; i<numberOfNodes; i++){
		if(i != src) {
			d[i] = numeric_limits<long double>::max();
		}
		else {
			d[i] = 0;
		}
	}

	// Dijkstra Algorithm
	Q.insert(make_pair(0,src));
	prevFixedNodeList[src] = src;

	while(Q.size()!=0) {
		long double minDist = Q.begin()->first;
		int nextHop   = Q.begin()->second;

		//cout << "Debug inside while(Q.size()!=0) and the size is " << Q.size() << endl;
		Q.erase(Q.begin());
		S.push_back(make_pair(nextHop, minDist));

		// Build path for each fixed vertex
		for (list<int>::iterator it = shortestPaths[prevFixedNodeList[nextHop]].begin(); it != shortestPaths[prevFixedNodeList[nextHop]].end(); it++) {
			//cout << "Debug 22:: " << *it << endl;
		    shortestPaths[nextHop].push_back(*it);
		}
		shortestPaths[nextHop].push_back(nextHop);

		list < pair<int, long double> >::iterator listIt = adjacencyList[nextHop].begin();
        //cout << "adjacencyList[3].size()=" << adjacencyList[3].size() << endl;
		for(; listIt != adjacencyList[nextHop].end(); listIt++) {
			//cout<< "Debug 11: for (*listIt).first:" << (*listIt).first << " (*listIt).second:" << (*listIt).second << "d[(*listIt).first]" << d[(*listIt).first] << endl;
			long double prevMin = d[(*listIt).first];
			long double couldBeMin = d[nextHop] + (*listIt).second;
			if( prevMin > couldBeMin) {
				d[(*listIt).first] = couldBeMin;
				Q.erase(make_pair(prevMin, (*listIt).first));
				//cout << "Debug 11: Hop to be pushed:" << (*listIt).first << endl;
				Q.insert(make_pair(couldBeMin, (*listIt).first));
				prevFixedNodeList[(*listIt).first] = nextHop;
			}
		}
	}

    string traversalFileName = outputLocation + "/traversalDetails.txt";
    ofstream traversalFilePtr;
    traversalFilePtr.open(traversalFileName.c_str());

	// Print the shortest distance for each other vertex
    traverseList.push_back(src);
	for(int i=0; i<numberOfNodes; i++) {

		//cout << "Shortest distance from source:" << src << " to vertex:" << i << " =" << d[i] << endl;
		//cout << " Size: " << shortestPaths[i].size() << " Path taken: " ;

		traversalFilePtr << "Shortest distance from source:" << src << " to vertex:" << i << " =" << d[i] << endl;
		traversalFilePtr << " Size: " << shortestPaths[i].size() << " Path taken: " ;

		for(list<int>::iterator it = shortestPaths[i].begin(); it != shortestPaths[i].end(); it++){
			//cout << *it << "-" ;
            if(i==dst)
                traverseList.push_back(*it);
			traversalFilePtr << *it << "-" ;
		}
		traversalFilePtr << endl;
	}
}
