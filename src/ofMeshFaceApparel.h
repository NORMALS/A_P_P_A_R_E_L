//
//  ofMeshFaceApparel.h
//  A_P_P_A_R_E_L
//
//  Created by Julien on 04/12/2014.
//
//

#pragma once
#include "ofMain.h"

class ofMeshFaceApparel : public ofMeshFace
{
	public:

		ofMeshFaceApparel(ofMesh*, int index);


		ofIndexType		getVertexIndex		(int index);
 		ofVec3f*		getVertexPointer	(int index);
 		int				getOffsetIndices	(){return m_offsetIndices;}
 
 
		ofMesh*			mp_mesh;
		int				m_offsetIndices;	// index (position) in the indices of ofMesh instance
};