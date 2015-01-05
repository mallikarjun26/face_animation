#include "ExtractFaces.hpp"

#include "boost/filesystem.hpp"
#include <boost/lexical_cast.hpp>
#include "opencv2/objdetect/objdetect.hpp"

#include <fstream>

using namespace boost::filesystem;

void extractFaces(const string videoLocation, const string outputLocation, const string haarCascadeXML) {
    cout << "Entered extractFaces function" << endl;

    // Handle for Video file capture
    VideoCapture captReference(videoLocation);

    // Check if video is valid
    if(!captReference.isOpened()){
        cout << "Couldn't open the reference " << videoLocation << endl;
        return;
    }

    // Prepare output folders and ask if the existing output can be deleted?
    string folderAllFaces = outputLocation;
    string facesFolder = outputLocation + "/faces";
    string wasteFacesFolder = outputLocation + "/wasteFaces";

    if(is_directory(folderAllFaces.c_str())) {
        char yesOrNo;
        cout << folderAllFaces << " already exists!" << endl << "Shall I go ahead delete it?" << endl;
        cin >> yesOrNo;
        if(yesOrNo == 'y'){
            remove_all(folderAllFaces.c_str());
        }
    }

    if( create_directory(folderAllFaces.c_str()) ) {
        cout << "Successfully created output directory" << endl;
    }
    else {
        cout << "Failed to create the output" << endl;
    }

    if( create_directory(facesFolder.c_str()) ) {
        cout << "Successfully created faces directory" << endl;
    }
    else {
        cout << "Failed to create the faces" << endl;
    }

    if( create_directory(wasteFacesFolder.c_str()) ) {
        cout << "Successfully created waste Faces directory" << endl;
    }
    else {
        cout << "Failed to create waste Faces directory" << endl;
    }

    string roiFolder = folderAllFaces + "/" + "ROI";
    if( create_directory(roiFolder.c_str()) ) {
        cout << "Successfully created ROI directory" << endl;
    }
    else {
        cout << "Failed to create the ROI directory" << endl;
    }

    // Handle for ROI file
    string roiFilePath = roiFolder + "/" + "ROI.txt";
    ofstream roiFileHandler;
    roiFileHandler.open(roiFilePath.c_str());

    // Window for display
    const char* FRAME_DISPLAY = "FRAME DISPLAY";
    const char* FACE_DISPLAY = "FACE DISPLAY";

    namedWindow(FRAME_DISPLAY, CV_WINDOW_AUTOSIZE);
    namedWindow(FACE_DISPLAY, CV_WINDOW_AUTOSIZE);

    // Get frames from the video
    Mat frameReference;
    uint32_t frameNumber=0;

    CascadeClassifier haar_cascade;
    haar_cascade.load(haarCascadeXML);

    for(;;) {
        captReference >> frameReference;

        if(frameReference.empty()) {
            cout << " < < ----Frames Over---- > >" << endl;
            roiFileHandler.close();
            return;
        }

        cout << "Frame Number: " << frameNumber << endl;
        imshow(FRAME_DISPLAY, frameReference);

        // Detect all the faces in this frame
        vector<Rect> facesInTheFrame;
        haar_cascade.detectMultiScale(frameReference, facesInTheFrame);

        for(uint i=0; i<facesInTheFrame.size(); i++) {
            Rect eachFaceROI = facesInTheFrame[i];
            Mat eachFace = frameReference(eachFaceROI);
            imshow(FACE_DISPLAY, eachFace);

            // Write the faces in the folder
            string tempFaceFileName = facesFolder + "/" + boost::lexical_cast<string>(frameNumber) + "_" + boost::lexical_cast<string>(i) + ".jpg";
            imwrite(tempFaceFileName, eachFace);

            // Save the ROI of the frames having faces
            roiFileHandler << frameNumber << "_" << i << " " << eachFaceROI.x << " " << eachFaceROI.y << " " << eachFaceROI.height << " " << eachFaceROI.width << endl;
        }

        cvWaitKey(10);
        frameNumber++;
    }

}
