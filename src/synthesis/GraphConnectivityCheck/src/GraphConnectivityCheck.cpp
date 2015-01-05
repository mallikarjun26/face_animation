//============================================================================
// Name        : GraphConnectivityCheck.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

/*
 * C++ Program to Check whether Undirected Graph is Connected using BFS
 */
#include <iostream>
#include <list>
#include <queue>
#include <fstream>
#include <vector>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <limits.h>
#include <map>

using namespace std;
using namespace boost;

/*
 * Class Declaration
 */
class Graph
{
    private:
        int V;
        list<int> *adj;
    public:
        Graph(int V)
        {
            this->V = V;
            adj = new list<int>[V];
        }
        void addEdge(int v, int w);
        void BFS(int s, bool visited[]);
        Graph getTranspose();
        bool isConnected();
};
 
/*
 * Add Edge to connect v and w
 */
void Graph::addEdge(int v, int w)
{
    adj[v].push_back(w);
    adj[w].push_back(v);
}
 
/*
 *  A recursive function to print BFS starting from s
 */
void Graph::BFS(int s, bool visited[])
{
    list<int> q;
    list<int>::iterator i;
    visited[s] = true;
    q.push_back(s);
    while (!q.empty())
    {
        s = q.front();
        q.pop_front();
        for(i = adj[s].begin(); i != adj[s].end(); ++i)
        {
            if(!visited[*i])
            {
                visited[*i] = true;
                q.push_back(*i);
            }
        }
    }
}
/*
 * Function that returns reverse (or transpose) of this graph
 */
Graph Graph::getTranspose()
{
    Graph g(V);
    for (int v = 0; v < V; v++)
    {
        list<int>::iterator i;
        for(i = adj[v].begin(); i != adj[v].end(); ++i)
        {
            g.adj[*i].push_back(v);
        }
    }
    return g;
}
/*
 * Check if Graph is Connected
 */
bool Graph::isConnected()
{
    bool visited[V];
    for (int i = 0; i < V; i++)
        visited[i] = false;
    BFS(0, visited);
    for (int i = 0; i < V; i++)
        if (visited[i] == false)
            return false;
    Graph gr = getTranspose();
    for(int i = 0; i < V; i++)
        visited[i] = false;
    gr.BFS(0, visited);
    for (int i = 0; i < V; i++)
        if (visited[i] == false)
            return false;
    return true;
}
/*
 * Main Contains Menu
 */
int main(int argc, char *argv[])
{

	if(argc != 3) {
		cout << "Number of arguments isn't correct \n";
		return -1;
	}
	else {
		cout << "Graph Connectivity Check running" << endl;
	}

	const string inputLocation       = argv[1];
	int edgeThreshold = lexical_cast<int>(argv[2]);

	//string TRACK_NETWORK_FILE = inputLocation + "/trackNetwork.txt";
	string TRACK_NETWORK_FILE = inputLocation;
	ifstream trackNetworkPtr(TRACK_NETWORK_FILE.c_str());

	string line;
	map<int, int> shotMap;
	vector<string> lineSplit;
	int mappedShotNumber = 0;


	if(!trackNetworkPtr.is_open()) {
		cout << "trackNetwork.txt isn't good!" << TRACK_NETWORK_FILE << endl  ;
		return -1;
	}

	getline(trackNetworkPtr, line);
	int numberOfShots = lexical_cast<int>(line);
	Graph g(numberOfShots);

	while(getline(trackNetworkPtr, line)) {
		split(lineSplit, line, is_any_of("-= "));
		int actualShotNumber1 = lexical_cast<int>(lineSplit[0]);
		int actualShotNumber2 = lexical_cast<int>(lineSplit[1]);
		float shotDissimilarity = lexical_cast<float>(lineSplit[2]);
		int mappedShotNumber1, mappedShotNumber2;

		if(shotMap.find(actualShotNumber1) == shotMap.end()) {
			shotMap[actualShotNumber1] = mappedShotNumber;
			mappedShotNumber1 = mappedShotNumber;
			mappedShotNumber++;
		}
		else {
			mappedShotNumber1 = shotMap[actualShotNumber1];
		}
		if(shotMap.find(actualShotNumber2) == shotMap.end()) {
			shotMap[actualShotNumber2] = mappedShotNumber;
			mappedShotNumber2 = mappedShotNumber;
			mappedShotNumber++;
		}
		else{
			mappedShotNumber2 = shotMap[actualShotNumber2];
		}

		if(shotDissimilarity < edgeThreshold)
			g.addEdge(mappedShotNumber1, mappedShotNumber2);

	}

	if(g.isConnected())
		cout<<"The Graph is Connected"<<endl;
	else
		cout<<"The Graph is not Connected"<<endl;

	/*
    Graph g(4);
    g.addEdge(0, 1);
    g.addEdge(0, 2);
    g.addEdge(5, 2);
    g.addEdge(2, 3);
    g.addEdge(3, 3);
    if (g.isConnected())
        cout<<"The Graph is Connected"<<endl;
    else
        cout<<"The Graph is not Connected"<<endl;
 
    Graph g1(5);
    g1.addEdge(0, 1);
    g1.addEdge(1, 2);
    g1.addEdge(2, 3);
    g1.addEdge(3, 0);
    g1.addEdge(2, 4);
    g1.addEdge(4, 2);
    if (g1.isConnected())
        cout<<"The Graph is Connected"<<endl;
    else
        cout<<"The Graph is not Connected"<<endl;
    */

    return 0;
}
