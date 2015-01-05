#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <boost/lexical_cast.hpp>

#include "ExtractFaces.hpp"
#include "FilterFaces.hpp"
#include "BuildListOfSelectedFaces.hpp"
#include "ConstructGraph.hpp"
#include "ExtractFrames.hpp"

#include <iostream>
#include <fstream>
#include <boost/algorithm/string.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/kruskal_min_spanning_tree.hpp>
#include <boost/lexical_cast.hpp>
#include <vector>

using namespace std;
using namespace cv;
using namespace boost;

void testing() {
    // Create an IplImage object *image
    Mat src= cvLoadImage("/home/mallikarjun/Documents/CV/ExpressionsSequencer/output/AllFaces/set_1/3669_0.jpg");
    Mat dst;
    Size sizeT(200,200);

    resize(src, dst, sizeT);
    const char* SRC_DISPLAY = "SRC";
    namedWindow(SRC_DISPLAY, CV_WINDOW_AUTOSIZE);
    const char* DST_DISPLAY = "DST";
    namedWindow(SRC_DISPLAY, CV_WINDOW_AUTOSIZE);
    namedWindow(DST_DISPLAY, CV_WINDOW_AUTOSIZE);
    imshow(SRC_DISPLAY, src);
    imshow(DST_DISPLAY, dst);

    cvWaitKey(2000000);

}


int main(int argc, char *argv[]) {

    if(argc != 6) {
        cout << "Not enough parameters" << endl;
        return -1;
    }

    const string videoLocation       = argv[1];
    const string outputLocation      = argv[2];
    const string haarCascadeXML      = argv[3];

    int  currentVertex               = lexical_cast<int>(argv[4]);
    int           setupPart          = lexical_cast<int>(argv[5]);

    int traversalType = 1;
    int featuresType  = 1;

    // Extract faces from the movie
    //extractFaces(videoLocation, outputLocation, haarCascadeXML);

    if(setupPart == 1) {

		// Filter faces in a given range of size and make them of same size
		//filterFaces(outputLocation);

		// Pose alignment of the faces

		// Build the list of all selected faces
		//buildListOfSelectedFaces(outputLocation);

		// Extract frames from the movie
		extractFrames(videoLocation, outputLocation, haarCascadeXML);

    }
    else {
    	// Build the graph out of all the facesBuildListOfSelectedFaces.cpp
    	//constructGraph(outputLocation, traversalType, featuresType, currentVertex );
    }
    // Find the interesting routes to come up with interesting sequences


    // Stage 2: Build a cube out of one particular expression sequence and find how another actor looks if he gives similar sort of sequence of expressions



	string listOfFacesFileName = outputLocation + "/ListOfFaces.txt";
	string TRAVERSAL_NAME = outputLocation + "/traversal.txt";
	string SHOTS_INFO_FILE    = outputLocation + "/frameShotMap.txt";

	ifstream listOfFacesFileNameHandle(listOfFacesFileName.c_str());
	ifstream traversalPtr(TRAVERSAL_NAME.c_str());
	ifstream shotsInfoPtr(SHOTS_INFO_FILE.c_str());

    list<int> traverseList;
	vector<string> faceMap;

//	findMappings(listOfFacesFileNameHandle, faceMap);
//
//	collectTravesal(traverseList, traversalPtr);
//
//	createVideo(traverseList, faceMap, outputLocation);

	//--------------------------------------------------------------------------
	vector<string> stringVector;
	string line;

	if(traversalPtr.is_open()) {
		if(getline(traversalPtr, line)) {
			split(stringVector, line, boost::is_any_of(" -"));

			for(int i=0; i<stringVector.size(); i++) {
				if(!stringVector[i].empty()){
					cout << "Debug : " << stringVector[i] << endl;
					int tempFaceNo = lexical_cast<int>(stringVector[i]);
					traverseList.push_back(tempFaceNo);
				}
			}

		}
	}


	//--------------------------------------------------------------------------
	//face map
	cout << "Collecting the mapping" << endl;
	if(listOfFacesFileNameHandle.is_open()) {
		while(getline(listOfFacesFileNameHandle, line)) {
			split(stringVector, line, boost::is_any_of(" "));
			//cout << "DEBUG 66:: stringVector[0]=" << stringVector[0] << endl;
			faceMap.push_back(stringVector[0]);
		}
	}

	//-------------------------------------------------------------------------
	// Build data structure for shots information
	cout << "Build data structure for shots information" << endl;
	int i=0, lastShot, shotNumber;
	vector<string> frameShotSplit;
	map<int, int> frameShotMap;
	if(shotsInfoPtr.is_open()) {
		while(getline(shotsInfoPtr, line)) {
			split(frameShotSplit, line, is_any_of("-="));
			lastShot = lexical_cast<int>(frameShotSplit[1]);
			shotNumber = lexical_cast<int>(frameShotSplit[2]);

			for(; i<lastShot; i++) {
				frameShotMap[i] = shotNumber;
			}
		}
	}

	//--------------------------------------------------------------------------
	VideoWriter outputVideo;
	//outputVideo.open(  , -1, 20, sizeT, true);
	outputVideo.open("/home/mallikarjun/Desktop/test2.avi", CV_FOURCC('D','I','V','X'), 15, Size (200, 200), true );
	if (!outputVideo.isOpened())
	{
		perror("Could not open the output video for write");
	}

    Mat faceMat, prevMat, midMat;

	bool firstTime_bool = true;
	cout << "Displaying the traversed faces" << endl;
	for(list<int>::iterator it=traverseList.begin(); it!=traverseList.end(); it++) {
		int faceNumber = *it;

		split(stringVector, faceMap[faceNumber], is_any_of("_"));
		int frameNo = lexical_cast<int>(stringVector[0]);
		string frameNumber = lexical_cast<string>(frameShotMap[frameNo]);

		string strTemp = outputLocation + "/faces/" +  faceMap[faceNumber];
		cout << "Debug:: " << strTemp << endl;

		faceMat = imread(strTemp.c_str(), CV_LOAD_IMAGE_COLOR);
		if(!firstTime_bool){
			addWeighted(prevMat, 0.5, faceMat, 0.5, 0, midMat, -1);
			//putText(midMat, "Bridge Image", cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << midMat;
			//putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			putText(faceMat, frameNumber.c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << faceMat;
		}
		else{
			//putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			putText(faceMat, frameNumber.c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << faceMat;
			firstTime_bool = false;
		}
		prevMat = faceMat.clone();

		//cvShowImage("mainWin", img );
		//cvWriteFrame(writer,img);
		//imshow(EXPRESSION_DISPLAY, faceMat);
		//cvWaitKey(10);
	}




    waitKey(50);
    return 0;

}



