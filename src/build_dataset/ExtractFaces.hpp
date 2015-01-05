#ifndef EXTRACTFACES_HPP_INCLUDED
#define EXTRACTFACES_HPP_INCLUDED

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>
#include "boost/filesystem.hpp"

using namespace std;
using namespace cv;

void extractFaces(const string videoLocation, const string outputLocation, const string haarCascadeXML);

#endif // EXTRACTFACES_HPP_INCLUDED
