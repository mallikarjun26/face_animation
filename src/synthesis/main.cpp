#include <iostream>
#include <fstream>
#include <boost/algorithm/string.hpp>
#include <boost/graph/adjacency_list.hpp>
#include <boost/lexical_cast.hpp>
#include <vector>

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include "ConstructGraph.hpp"

using namespace std;
using namespace cv;
using namespace boost;

int main(int argc, char *argv[]) {
  
  string outputLocation = argv[1];    

  constructGraph(outputLocation, 10);

}

