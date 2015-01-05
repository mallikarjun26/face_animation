//============================================================================
// Name        : VideoSynthesis.cpp
// Author      : 
// Version     :
// Copyright   : Your copyright notice
// Description : Hello World in C++, Ansi-style
//============================================================================

#include <iostream>
#include <fstream>
#include <boost/algorithm/string.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/graph/kruskal_min_spanning_tree.hpp>
#include <boost/lexical_cast.hpp>
#include <vector>

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

using namespace std;
using namespace boost;
using namespace cv;

/*
void collectTravesal(list<int> &traverseList, ifstream traversalPtr){

	vector<string> stringVector;
	string line;

	if(traversalPtr.is_open()) {
		if(getline(traversalPtr, line)) {
			split(stringVector, line, boost::is_any_of(" -"));

			for(int i=0; i<stringVector.size(); i++) {
				//if(!stringVector[i]){
					int tempFaceNo = lexical_cast<int>(stringVector[i]);
					traverseList.push_back(tempFaceNo);
				//}
			}

		}
	}

}

void findMappings(ifstream listOfFacesFileNameHandle, vector<string> &faceMap) {

	vector<string> stringVector;
	string line;

	cout << "Collecting the mapping" << endl;
	if(listOfFacesFileNameHandle.is_open()) {
		while(getline(listOfFacesFileNameHandle, line)) {
			split(stringVector, line, boost::is_any_of(" "));
			//cout << "DEBUG 66:: stringVector[0]=" << stringVector[0] << endl;
			faceMap.push_back(stringVector[0]);
		}
	}

}

void createVideo(list<int> &traverseList, vector<string> &faceMap, string outputLocation) {

	VideoWriter outputVideo;
	//outputVideo.open(  , -1, 20, sizeT, true);
	outputVideo.open("/home/mallikarjun/Desktop/test2.avi", CV_FOURCC('D','I','V','X'), 5, Size (200, 200), true );
	if (!outputVideo.isOpened())
	{
		perror("Could not open the output video for write");
	}

    Mat faceMat, prevMat, midMat;

	bool firstTime_bool = true;
	cout << "Displaying the traversed faces" << endl;
	for(list<int>::iterator it=traverseList.begin(); it!=traverseList.end(); it++) {
		int faceNumber = *it;

		string strTemp = outputLocation + "/AllFaces/Faces5000/" +  faceMap[faceNumber];

		faceMat = imread(strTemp.c_str(), CV_LOAD_IMAGE_COLOR);
		if(!firstTime_bool){
			addWeighted(prevMat, 0.5, faceMat, 0.5, 0, midMat, -1);
			//putText(midMat, "Bridge Image", cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << midMat;
			putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << faceMat;
		}
		else{
			putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << faceMat;
			firstTime_bool = false;
		}
		prevMat = faceMat.clone();

		//cvShowImage("mainWin", img );
		//cvWriteFrame(writer,img);
		//imshow(EXPRESSION_DISPLAY, faceMat);
		//cvWaitKey(10);
	}

}
*/

int main(int argc, char *argv[]) {

	if(argc != 2){
		cout << "No of input args aren't right" << endl;
		return -1;
	}

	string outputLocation = argv[1];

	string listOfFacesFileName = outputLocation + "/ListOfFaces.txt";
	string TRAVERSAL_NAME = outputLocation + "/traversal.txt";

	ifstream listOfFacesFileNameHandle(listOfFacesFileName.c_str());
	ifstream traversalPtr(TRAVERSAL_NAME.c_str());

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
				//if(!stringVector[i]){
					int tempFaceNo = lexical_cast<int>(stringVector[i]);
					traverseList.push_back(tempFaceNo);
				//}
			}

		}
	}


	//--------------------------------------------------------------------------
	cout << "Collecting the mapping" << endl;
	if(listOfFacesFileNameHandle.is_open()) {
		while(getline(listOfFacesFileNameHandle, line)) {
			split(stringVector, line, boost::is_any_of(" "));
			//cout << "DEBUG 66:: stringVector[0]=" << stringVector[0] << endl;
			faceMap.push_back(stringVector[0]);
		}
	}

	//--------------------------------------------------------------------------
	VideoWriter outputVideo;
	//outputVideo.open(  , -1, 20, sizeT, true);
	outputVideo.open("/home/mallikarjun/Desktop/test2.avi", CV_FOURCC('D','I','V','X'), 5, Size (200, 200), true );
	if (!outputVideo.isOpened())
	{
		perror("Could not open the output video for write");
	}

    Mat faceMat, prevMat, midMat;

	bool firstTime_bool = true;
	cout << "Displaying the traversed faces" << endl;
	for(list<int>::iterator it=traverseList.begin(); it!=traverseList.end(); it++) {
		int faceNumber = *it;

		string strTemp = outputLocation + "/AllFaces/Faces5000/" +  faceMap[faceNumber];

		faceMat = imread(strTemp.c_str(), CV_LOAD_IMAGE_COLOR);
		if(!firstTime_bool){
			addWeighted(prevMat, 0.5, faceMat, 0.5, 0, midMat, -1);
			//putText(midMat, "Bridge Image", cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << midMat;
			putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << faceMat;
		}
		else{
			putText(faceMat, faceMap[faceNumber].c_str(), cvPoint(30,30), FONT_HERSHEY_COMPLEX_SMALL, 0.8, cvScalar(200,200,250), 1, CV_AA);
			outputVideo << faceMat;
			firstTime_bool = false;
		}
		prevMat = faceMat.clone();

		//cvShowImage("mainWin", img );
		//cvWriteFrame(writer,img);
		//imshow(EXPRESSION_DISPLAY, faceMat);
		//cvWaitKey(10);
	}
}
