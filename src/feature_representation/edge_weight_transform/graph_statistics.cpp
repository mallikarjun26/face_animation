// Provides minimum, average and maximum edge weights between tracks and within tracks

/*
 * main.cpp
 *
 *  Created on: 04-Aug-2014
 *      Author: mallikarjun
 */

#include <iostream>
#include <fstream>
#include <vector>
#include <boost/algorithm/string.hpp>
#include <boost/lexical_cast.hpp>
#include <limits.h>
#include <map>

using namespace std;
using namespace boost;

class Shot {
public:
	float min_dist;
	float avg_dist;
	float max_dist;
	int no_edges;
	/*Shot() {
		min_dist=0;
		avg_dist=0;
		max_dist=FLT_MAX;
		no_edges=0;
	}
*/
};

int get_across_track_min_weight_avg(string outputLocation) {

    float across_track_min_weight_avg=0;
    int   number_of_across_track=0;

	string LIST_OF_FACES_FILE = outputLocation + "/ListOfFaces.txt";
	string EDGE_WEIGHTS_FILE  = outputLocation + "/edgeWeights.txt";
	string SHOTS_INFO_FILE    = outputLocation + "/frameShotMap.txt";
	string SHOTS_NETWORK_FILE = outputLocation + "/trackNetwork.txt";

	ifstream edgeWeightsPtr(EDGE_WEIGHTS_FILE.c_str());
	ifstream shotsInfoPtr(SHOTS_INFO_FILE.c_str());
	ifstream listOfFacesPtr(LIST_OF_FACES_FILE.c_str());
	ofstream trackNetworkPtr(SHOTS_NETWORK_FILE.c_str());

	string line;
	map<int, int> frameShotMap;
	map<int, map<int, Shot> > trackNetwork;
	map<int, int> nodeFrameMap;

	// Actual frame number map
	cout << "Actual frame number mapping" << endl;
	vector<string> frameMapSplit;
	if(listOfFacesPtr.is_open()) {
		while(getline(listOfFacesPtr, line)) {
			split(frameMapSplit, line, is_any_of("_ "));
			int frameNo  = lexical_cast<int>(frameMapSplit[0]);
			int node     = lexical_cast<int>(frameMapSplit[2]);
			//cout << "node:" << node << " frameNo:" << frameNo << endl;
			nodeFrameMap[node] = frameNo;
		}
	}

	// Build data structure for shots information
	cout << "Build data structure for shots information" << endl;
	int i=0, lastShot, shotNumber;
	vector<string> frameShotSplit;
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

	// Build the min, avg and max values within and between the shots.
	cout << "Build the min, avg and max values within and between the shots" << endl;
	vector<string> edgeWeightSplit;
	int node1, node2;
	float edgeWeight;
	int frame1, frame2;
	int track1, track2;

	if(edgeWeightsPtr.is_open()) {

		getline(edgeWeightsPtr,line);
        //cout << line << endl;
		while(getline(edgeWeightsPtr,line)) {
            //cout << line << endl;
			split(edgeWeightSplit, line, is_any_of("-="));
			node1  = lexical_cast<int>(edgeWeightSplit[0]);
			node2  = lexical_cast<int>(edgeWeightSplit[1]);
			frame1 = nodeFrameMap[node1];
			frame2 = nodeFrameMap[node2];
			edgeWeight = lexical_cast<float>(edgeWeightSplit[2]);

			if(frameShotMap[frame1] < frameShotMap[frame2]) {
				track1 = frameShotMap[frame1];
				track2 = frameShotMap[frame2];
			}
			else {
				track1 = frameShotMap[frame2];
				track2 = frameShotMap[frame1];
			}

			//cout << "node1:" << node1 << " frame1:" << frame1 << " node2:" << node2 << " frame2:" << frame2 << " track1:" << track1 << " track2:" << track2 << " edgeWeight:" << edgeWeight << endl;

			// Mapping Shot of Shot info. First level shot number is less than or equal to second level shot number
			if(trackNetwork.find(track1) != trackNetwork.end()){ // outer map is present
				if(trackNetwork[track1].find(track2) != trackNetwork[track1].end() ) { // Inner map also present
					//cout << "Debug 1" << endl;
					map<int, Shot> tempShotMap = trackNetwork[track1];
					Shot tempShot = tempShotMap[track2];
					if(tempShot.min_dist > edgeWeight) // min value
						tempShot.min_dist = edgeWeight;
					if(tempShot.max_dist < edgeWeight) // min value
						tempShot.max_dist = edgeWeight;
					tempShot.avg_dist += edgeWeight;
					tempShot.no_edges++;

					tempShotMap[track2] = tempShot;
					trackNetwork[track1] = tempShotMap;
				}
				else { // Inner map isn't there
					//cout << "Debug 2" << endl;
					map<int, Shot> tempShotMap = trackNetwork[track1];
					Shot tempShot;
					tempShot.min_dist = edgeWeight;
					tempShot.avg_dist = edgeWeight;
					tempShot.max_dist = edgeWeight;
					tempShot.no_edges = 1;

					tempShotMap[track2] = tempShot;
					trackNetwork[track1] = tempShotMap;
				}
			}
			else { // Outer map isn't present
				//cout << "Debug 3" << endl;
				map<int, Shot> tempShotMap;
				Shot tempShot;
				tempShot.min_dist = edgeWeight;
				tempShot.avg_dist = edgeWeight;
				tempShot.max_dist = edgeWeight;
				tempShot.no_edges = 1;

				tempShotMap[track2] = tempShot;
				trackNetwork[track1] = tempShotMap;
			}

		}
	}

	// Writing the shotsNetwork info in a file.
	cout << "Writing the shotsNetwork info in a file" << endl;
	if(trackNetworkPtr.is_open()) {
		map<int, map<int, Shot> >::iterator outer_it = trackNetwork.begin();

		//cout << "Debug 00. trackNetwork.size()=" << trackNetwork.size() << endl;
		trackNetworkPtr << "Number of Shots=" << trackNetwork.size() << endl;
		for(; outer_it!=trackNetwork.end(); outer_it++) {
			//cout << "Debug 00" << endl;
			int outerShotNumber                    = (*outer_it).first;
			//cout <<  "Debug 00 outerShotNumber=" << outerShotNumber << endl;
			map<int, Shot> innerNetwork            = (*outer_it).second;
			map<int, Shot>::iterator inner_it      = innerNetwork.begin();
			for(; inner_it!=innerNetwork.end(); inner_it++) {
				//cout << "Debug 11" << endl;
				int innerShotNumber    =  (*inner_it).first;
				Shot tempShot          =  (*inner_it).second;

				tempShot.avg_dist = tempShot.avg_dist / tempShot.no_edges;

				(*inner_it).second = tempShot;

				trackNetworkPtr << outerShotNumber << "-" << innerShotNumber << "=" << tempShot.min_dist << " " << tempShot.avg_dist << " " << tempShot.max_dist << tempShot.no_edges << endl;
				//cout << outerShotNumber << "-" << innerShotNumber << "=" << tempShot.min_dist << " " << tempShot.avg_dist << " " << tempShot.max_dist << tempShot.no_edges << endl;

                if(outerShotNumber != innerShotNumber) {
                    number_of_across_track++;
                    across_track_min_weight_avg += tempShot.min_dist;
                }    

			}
		}
	}
    if(number_of_across_track) {
        cout << "across_track_min_weight_avg = " << across_track_min_weight_avg << "number_of_across_track = " << number_of_across_track << endl;
        across_track_min_weight_avg = across_track_min_weight_avg / number_of_across_track;
        return (across_track_min_weight_avg);
    }
}


