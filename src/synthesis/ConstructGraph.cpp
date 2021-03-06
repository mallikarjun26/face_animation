#include <iostream>
#include <fstream>
#include <boost/algorithm/string.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/kruskal_min_spanning_tree.hpp>
#include <boost/lexical_cast.hpp>
#include <vector>
#include <stdlib.h>

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include "Node.hpp"
#include "TraversalDijkstra.hpp"

using namespace std;
using namespace boost;
using namespace cv;


int findNextVertex(int currentVertex, map<int, list < pair<int, long double > > > &adjacencyList, int &noOfVerticesLeft, long double &nextHopDistance) {

    list< pair<int, long double > >::iterator it=adjacencyList[currentVertex].begin();

    int nextVertex;
    long double  leastDist;

    while(adjacencyList[(*it).first].size()==0) {
        it++;
    }
    nextVertex   = (*it).first;
    leastDist  = (*it).second;

    //cout << "Debug ! nextVertex:" << nextVertex << " leastDist:" << leastDist << endl;

    it=adjacencyList[currentVertex].begin();
    for (; it!=adjacencyList[currentVertex].end(); ++it) {
        //cout << "(*it).second=" << (*it).second << " leastDist" << leastDist << endl;
        if(((*it).second <= leastDist) && (adjacencyList[(*it).first].size() > 0) ){
            nextVertex  = (*it).first;
            leastDist   = (*it).second;
            //cout << "Debug ! nextVertex:" << nextVertex << " leastDist:" << leastDist << endl;
        }
    }
    //cout << "Selected Debug ! nextVertex:" << nextVertex << " leastDist:" << lexical_cast<string>(leastDist) << endl;
    nextHopDistance = leastDist;

    adjacencyList[currentVertex].clear();
    noOfVerticesLeft--;

    return(nextVertex);
}

void traversalGreedyNextHop(map< int, list < pair<int, long double > > > &adjacencyList, list<int> &traverseList, list<long double> &traverseDistanceList, int currentVertex, int numberOfHops, int noOfVerticesLeft) {

	cout << "Entered traversalGreedyNextHop " << endl;
	traverseList.push_back(currentVertex);
    long double nextHopDistance;

	int nextVertex = findNextVertex(currentVertex, adjacencyList, noOfVerticesLeft, nextHopDistance);
	// cout << "Debug 44:: Next Vertex" << nextVertex << "adjacencyList size:" << adjacencyList.size() << endl;

	int debugWhile = 0;
	while((noOfVerticesLeft!=1) && (numberOfHops > 1)){
        // cout << "Debug 55:: Inside while. Next Vertex:: " << nextVertex << " VerticesLeft:: " << noOfVerticesLeft << " debugWhile::" << debugWhile << endl;
        traverseList.push_back(nextVertex);
        traverseDistanceList.push_back(nextHopDistance);
        currentVertex = nextVertex;
        nextVertex = findNextVertex(currentVertex, adjacencyList, noOfVerticesLeft, nextHopDistance);
        debugWhile++;
	numberOfHops--;
    }
}

map<int, list < pair<int, long double > > > getGraph(string edgeWeightsTxtName, int& noOfVertices) {

    cout << "Building adjacencyList !" << endl;	

    ifstream edgeWeightPtr(edgeWeightsTxtName.c_str());

    int                                                 vertexA, vertexB;
    long double                                              edgeWeight;
    map<int, list < pair<int, long double > > > adjacencyList;
    string line;

    // Open the file to read all the edge weights.
    if(edgeWeightPtr.is_open()) {

        // Line 1 contains, number of vertices.
        if(getline(edgeWeightPtr, line)) {
            try {
                noOfVertices      = lexical_cast<int>(line);
            }
            catch(bad_lexical_cast const&) {
                cout << "Error: input string was not valid:" << line << endl;
            }
        }

        // Read each edge weights.
        int lineCount =1;
        while(getline(edgeWeightPtr, line)) {
			//cout << line << endl;
        	vector<string> stringVector, stringVector_1;

			try {
			    split(stringVector, line, boost::is_any_of("="));

			    edgeWeight = lexical_cast<long double >(stringVector[1].c_str());

			    split(stringVector_1, stringVector[0], boost::is_any_of("-"));
                
			    vertexA = lexical_cast<int>(stringVector_1[0].c_str());
			    vertexB = lexical_cast<int>(stringVector_1[1].c_str());
			    
                //cout << "vertexA=" << vertexA << " vertexB=" << vertexB << " edgeWeight=" << edgeWeight << endl;
			}
			catch (bad_lexical_cast const&) {
				cout << "Error: input string was not valid" << line  << endl;
			}

			if(adjacencyList.find(vertexA) != adjacencyList.end()){
				list < pair<int, long double > > tempList = adjacencyList[vertexA];
				tempList.push_back(make_pair(vertexB, edgeWeight));
				adjacencyList[vertexA] = tempList;
			}
			else{
				list < pair<int, long double > > tempList;
				tempList.push_back(make_pair(vertexB, edgeWeight));
				adjacencyList[vertexA] =  tempList;
			}

			if(adjacencyList.find(vertexB) != adjacencyList.end()){
				list < pair<int, long double > > tempList = adjacencyList[vertexB];
				tempList.push_back(make_pair(vertexA, edgeWeight));
				adjacencyList[vertexB] = tempList;
			}
			else{
				list < pair<int, long double > > tempList;
				tempList.push_back(make_pair(vertexA, edgeWeight));
				adjacencyList[vertexB] =  tempList;
			}

			if(lineCount%10000==0)
				cout << "Here I'm in the loop of getting edgeWeights " << lineCount << "/" << noOfVertices << endl;
			lineCount++;
        }
        //cout << "while returning adjacencyList[3].size()=" << adjacencyList[3].size() << endl;
	    return adjacencyList;
    }
    else {
        cout << "Couldn't open " << edgeWeightsTxtName << endl;
        return adjacencyList;
    }

}

void getVideo(list<int> traverseList, list<long double> traverseDistanceList, string videoOutput, string outputLocation) {

    string videoOutput_path              = videoOutput + ".avi";
    string traverse_hop_distance_path    = videoOutput + "_hop_distances.txt";
    string node_list_path                = videoOutput + "_node_list.txt";
    string line;
    vector<string> stringVector;
    ofstream traverse_hop_distance_ptr(traverse_hop_distance_path.c_str());
    ofstream node_list_ptr(node_list_path);

    // Print the traverse route
    // cout << "Final traversal of Vertices and size" << traverseList.size() << endl;
    // for(list<int>::iterator it=traverseList.begin(); it!=traverseList.end(); it++) {
    //     cout << *it << " - ";
    // }
    // cout << endl;


    // Display the video
    cout << "Entered getVideo" << endl;
    string listOfFacesFileName = outputLocation + "/ListOfFaces.txt";
    ifstream listOfFacesFileNameHandle(listOfFacesFileName.c_str());
    vector<string> faceMap;

    //cout << "Collecting the mapping" << endl;
    if(listOfFacesFileNameHandle.is_open()) {
        while(getline(listOfFacesFileNameHandle, line)) {
            split(stringVector, line, boost::is_any_of(" "));
            //cout << "DEBUG 66:: stringVector[0]=" << stringVector[0] << endl;
            faceMap.push_back(stringVector[0]);
        }
    }

    Mat faceMat, prevMat, midMat;
    //const char* EXPRESSION_DISPLAY = "Expressions";
    //namedWindow(EXPRESSION_DISPLAY, CV_WINDOW_AUTOSIZE);

    // Display the traversed faces and make a video of the same
    VideoWriter outputVideo;
    // outputVideo.open("/home/mallikarjun/Desktop/test2.avi", CV_FOURCC('D','I','V','X'), 5, Size (200, 200), true );
    outputVideo.open(videoOutput_path, CV_FOURCC('P','I','M','1'), 24, Size (200, 200), true );
    if (!outputVideo.isOpened())
    {
        perror("Could not open the output video for write");
    }

    bool firstTime_bool = true;
    // cout << "Displaying the traversed faces" << endl;
    int i=0;
    //cout << "traverseList.size()=" << traverseList.size() << endl;
    for(list<int>::iterator it=traverseList.begin(); it!=traverseList.end(); it++) {
        int faceNumber = *it;
        node_list_ptr << faceNumber << endl;
        //cout << "DEBUG 88:: faceMap[i]=" << faceMap[faceNumber] << endl;
        string strTemp = outputLocation + "/faces/" +  faceMap[faceNumber];
        //cout << "DEBUG 77:: strTemp=" << strTemp << endl;
        //IplImage* img=cvLoadImage(strTemp.c_str());
        faceMat = imread(strTemp.c_str(), CV_LOAD_IMAGE_COLOR);
        if(!firstTime_bool){
            //cout << "debug number=" << i << endl;
            //addWeighted(prevMat, 0.5, faceMat, 0.5, 0, midMat, -1);
            //putText(midMat, "Bridge Image", cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
            //outputVideo << midMat;
            putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
            outputVideo << faceMat;
            traverse_hop_distance_ptr << traverseDistanceList.front() << " ";
            traverseDistanceList.pop_front();
        }
        else{
            //cout << "debug number=" << i << endl;
            putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
            outputVideo << faceMat;
            firstTime_bool = false;
        }
        prevMat = faceMat.clone();

        //cvShowImage("mainWin", img );
        //cvWriteFrame(writer,img);
        //imshow(EXPRESSION_DISPLAY, faceMat);
        cvWaitKey(10);
        i++;
    }
    traverse_hop_distance_ptr.close();
    node_list_ptr.close();
 
}


void synthesizeVideo(const string outputLocation, map<int, list < pair<int, long double > > > adjacencyList, int videoNumber, int noOfVertices, int vertex1, int vertex2) {

    string videoOutput_g = outputLocation + "/videos/" + "greedNextHop_" + to_string(videoNumber);
    string videoOutput_d = outputLocation + "/videos/" + "dijkstra_" + to_string(videoNumber);
    string line;
    vector<string> stringVector;
    list<int> traverseList;

    // Traverse the graph
    list<int> traverseList_g, traverseList_d;
    list<long double> traverseDistanceList_g, traverseDistanceList_d;

    traversalGreedyNextHop(adjacencyList, traverseList_g, traverseDistanceList_g, vertex1, 500, noOfVertices); 
    traversalDijkstra(noOfVertices, vertex1, vertex2, adjacencyList, traverseList_d, traverseDistanceList_d, outputLocation) ; 

    cout << "traverseDistanceList_d=" << traverseDistanceList_d.size() << " traverseDistanceList_g=" << traverseDistanceList_g.size() << endl; 
    cout << "traverseList_d=" << traverseList_d.size() << " traverseList_g=" << traverseList_g.size() << endl; 

    getVideo(traverseList_g, traverseDistanceList_g, videoOutput_g, outputLocation);
    getVideo(traverseList_d, traverseDistanceList_d, videoOutput_d, outputLocation);

}

void constructGraph(std::string outputLocation, int numberOfVideos){
    cout << "Entered constructGraph " << endl;

    int noOfVertices, noOfVideos = 100;
    string line;
    vector<string> stringVector;
    string edgeWeightsTxtName = outputLocation + "/edgeWeights.txt";
    map<int, list < pair<int, long double > > > adjacencyList;

    adjacencyList = getGraph(edgeWeightsTxtName, noOfVertices);

    if(adjacencyList.size() < 1) {
        cout << "Graph is NULL !" << endl;
    }

    for(int i=0; i<noOfVideos; i++) {
    	int vertex1 = rand() % noOfVertices;         
	    int vertex2 = rand() % noOfVertices;         
        synthesizeVideo(outputLocation, adjacencyList, i, noOfVertices, vertex1, vertex2); 
    }

}


