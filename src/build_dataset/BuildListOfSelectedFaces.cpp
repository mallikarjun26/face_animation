#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>
#include "boost/filesystem.hpp"

#include <dirent.h>

#include <fstream>

using namespace std;
using namespace cv;

void buildListOfSelectedFaces(const string outputLocation) {

    int noOfFaces=0;
    ofstream listOfFaces_ptr;
    string name_listOfFaces = outputLocation + "/ListOfFaces.txt";
    string facesFolder = outputLocation + "/faces";
    listOfFaces_ptr.open(name_listOfFaces.c_str());

    struct dirent *dirPtr_l;

    DIR *dirPtr = opendir(facesFolder.c_str());

    while((dirPtr_l = readdir(dirPtr)) != NULL) {

        if( strcmp(dirPtr_l->d_name, ".") != 0 && strcmp(dirPtr_l->d_name, "..") != 0 ){
            cout << dirPtr_l->d_name << endl;
            listOfFaces_ptr << dirPtr_l->d_name << " " << noOfFaces << endl;
            noOfFaces++;
        }

    }
}
