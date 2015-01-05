/*
 * ExtractFrames.cpp
 *
 *  Created on: 12-Jul-2014
 *      Author: mallikarjun
 */


#include "ExtractFrames.hpp"
#include <boost/algorithm/string.hpp>
#include "boost/filesystem.hpp"
#include <boost/lexical_cast.hpp>
#include "opencv2/objdetect/objdetect.hpp"

#include <fstream>

using namespace boost::filesystem;

void extractFrames(const string videoLocation, const string outputLocation, const string haarCascadeXML) {
    cout << "Entered extractFaces function" << endl;

    // Handle for Video file capture
    VideoCapture captReference(videoLocation);

    // Check if video is valid
    if(!captReference.isOpened()){
        cout << "Couldn't open the reference " << videoLocation << endl;
        return;
    }

    // Prepare output folders and ask if the existing output can be deleted?
    string folderAllFrames = outputLocation + "/Frames";

    if(is_directory(folderAllFrames.c_str())) {
        char yesOrNo;
        cout << folderAllFrames << " already exists!" << endl << "Shall I go ahead delete it?" << endl;
        cin >> yesOrNo;
        if(yesOrNo == 'y'){
            remove_all(folderAllFrames.c_str());
        }
    }

    if( create_directory(folderAllFrames.c_str()) ) {
        cout << "Successfully created Frames directory" << endl;
    }
    else {
        cout << "Failed to create the folder Frames" << endl;
    }

    // Window for display
    const char* FRAME_DISPLAY = "FRAME DISPLAY";
    const char* FACE_DISPLAY = "FACE DISPLAY";

    namedWindow(FRAME_DISPLAY, CV_WINDOW_AUTOSIZE);
    namedWindow(FACE_DISPLAY, CV_WINDOW_AUTOSIZE);

    // Get list of frames to be collected
    string listOfFramesName = outputLocation + "/ListOfFaces.txt";
    ifstream listOfFramesPtr(listOfFramesName.c_str());
    string line;
    vector<string> stringVector;
    map<int, bool> frameMap;

    if(listOfFramesPtr.is_open()) {

    	while(getline(listOfFramesPtr, line)) {
    		//cout << "Debug 11: " << line << endl;
    		split(stringVector, line, boost::is_any_of(" ._"));
    		try {
    			int t_frameNumber= boost::lexical_cast<int>(stringVector[0]);
    			frameMap[t_frameNumber] = true;
    			//cout << "Debug 00: t_frameNumber:" << t_frameNumber << endl;
            }
            catch(boost::bad_lexical_cast const&) {
                cout << "Error: input string was not valid" << endl;
            }
    	}
    }
    else {
    	cout << "Couldn't open " << listOfFramesName << endl;
    	return;
    }


    // Get frames from the video
    Mat frameReference;
    uint32_t frameNumber=0;

    CascadeClassifier haar_cascade;
    haar_cascade.load(haarCascadeXML);

    for(;;) {
        captReference >> frameReference;

        if(frameReference.empty()) {
            cout << " < < ----Frames Over---- > >" << endl;
            return;
        }

        cout << "Frame Number: " << frameNumber << endl;
        //imshow(FRAME_DISPLAY, frameReference);

        if(frameMap.find(frameNumber) != frameMap.end()){
        	string tempFaceFileName = folderAllFrames + "/" + boost::lexical_cast<string>(frameNumber) + ".jpg";
        	imwrite(tempFaceFileName, frameReference);
        }

        //cvWaitKey(10);
        frameNumber++;
    }

}


