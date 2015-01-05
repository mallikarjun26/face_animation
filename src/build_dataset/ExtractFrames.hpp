/*
 * ExtractFrames.hpp
 *
 *  Created on: 12-Jul-2014
 *      Author: mallikarjun
 */

#ifndef EXTRACTFRAMES_HPP_
#define EXTRACTFRAMES_HPP_

#include <opencv2/core/core.hpp>
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/highgui/highgui.hpp>

#include <iostream>
#include "boost/filesystem.hpp"

using namespace std;
using namespace cv;

void extractFrames(const string videoLocation, const string outputLocation, const string haarCascadeXML);



#endif /* EXTRACTFRAMES_HPP_ */
