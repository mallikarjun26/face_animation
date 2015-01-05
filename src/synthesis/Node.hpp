/*
 * Node.hpp
 *
 *  Created on: 05-Jul-2014
 *      Author: mallikarjun
 */

#ifndef NODE_HPP_
#define NODE_HPP_

class Node {
	public:
		int id;
		float distance;

	Node(int id_t, int distance_t) {
		id = id_t;
		distance = distance_t;
	}

	void set(int id_t, int distance_t) {
		id = id_t;
		distance = distance_t;
	}
};


#endif /* NODE_HPP_ */
