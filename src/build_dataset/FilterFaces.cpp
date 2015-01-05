#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>
#include "boost/filesystem.hpp"

#include <dirent.h>

#include <fstream>

using namespace std;
using namespace cv;

void filterFaces(const string ouputLocation){


	string finalFacesLocation = ouputLocation + "/faces";
    cout << "Entered Filtering task" << endl;

    Mat faceMat;
    struct dirent *dirPtr_l;
    DIR *dirPtr = opendir(finalFacesLocation.c_str());

    while((dirPtr_l = readdir(dirPtr)) != NULL) {
        string fileName = dirPtr_l->d_name;
        //cout << "DEBUG 00: Inside while=" << fileName << " :: " << finalFacesLocation <<endl;
        if( strcmp(dirPtr_l->d_name, ".") != 0 && strcmp(dirPtr_l->d_name, "..") != 0 ){

            //cout << dirPtr_l->d_name << endl;
            string oldPath = finalFacesLocation + "/" + fileName;
            faceMat = imread(oldPath.c_str(), CV_LOAD_IMAGE_COLOR);

            if( (faceMat.rows<70) || (faceMat.cols<70)) {
                string newPath = finalFacesLocation + "/../wasteFaces/" + fileName;
                //cout << "DEBUG 11: Inside if :: " << faceMat.rows << ":" << faceMat.cols << " :: "  << oldPath << " :: " << newPath << endl;
                int result = rename(oldPath.c_str(), newPath.c_str());

                if(result != 0) {
                    perror("Couldn't move the file");
                }

            }
            else {
                Mat dst;
                Size sizeT(200, 200);
                resize(faceMat, dst, sizeT);
                imwrite(oldPath.c_str(), dst);
            }
        }
    }
}
