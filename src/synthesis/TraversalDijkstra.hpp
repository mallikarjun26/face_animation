/*
 * TraversalDijkstra.hpp
 *
 *  Created on: 06-Jul-2014
 *      Author: mallikarjun
 */

#ifndef TRAVERSALDIJKSTRA_HPP_
#define TRAVERSALDIJKSTRA_HPP_

#include <vector>
#include <list>

using namespace std;

void traversalDijkstra(int numberOfNodes, int src, int dst, map<int, list < pair<int, double> > > adjacencyList, list<int> traverseList, const string outputLocation);


#endif /* TRAVERSALDIJKSTRA_HPP_ */
