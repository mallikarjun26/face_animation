#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <boost/lexical_cast.hpp>

#include "ExtractFaces.hpp"
#include "FilterFaces.hpp"
#include "BuildListOfSelectedFaces.hpp"
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

int main(int argc, char *argv[]) {

    if(argc != 2) {
        cout << "Please provide output location folder" << endl;
        return -1;
    }

    const string outputLocation      = argv[1];
    const string videoLocation       = outputLocation + "/../rest/As Good As It Gets [1997].avi";
    const string haarCascadeXML      = "./haarcascade_frontalface_default.xml";

    // Extract faces from the movie
    //extractFaces(videoLocation, outputLocation, haarCascadeXML);

	// Filter faces in a given range of size and make them of same size
	//filterFaces(outputLocation);

	// Pose alignment of the faces

	// Build the list of all selected faces
	//buildListOfSelectedFaces(outputLocation);

	// Extract frames from the movie
	extractFrames(videoLocation, outputLocation, haarCascadeXML);

    return 0;

}



