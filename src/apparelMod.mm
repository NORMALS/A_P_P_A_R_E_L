//
//  apparelMod.cpp
//  A_P_P_A_R_E_L
//
//  Created by Julien on 27/05/2014.
//
//

#include "apparelMod.h"
#include "globals.h"
#ifdef TARGET_OF_IOS
#include "ofxIOSExtras.h"
#endif

//--------------------------------------------------------------

//--------------------------------------------------------------
apparelMod::apparelMod(string id)
{
	m_id 			= id;
	mp_model 		= 0;
	mp_oscSender 	= 0;
	
	m_isActive.setName("Active");
	m_parameters.add(m_isActive);

	m_weight.set("Weight", 0.5f, 0.0f, 1.0f);
	m_parameters.add(m_weight);

	m_parameters.setName(id);
}

//--------------------------------------------------------------
ofAbstractParameter& apparelMod::getParameter(string name)
{
	return m_parameters.get(name);
}

//--------------------------------------------------------------
void apparelMod::addFaceIndex(int faceIndex)
{
	m_indicesFaces.push_back(faceIndex);
}

//--------------------------------------------------------------
void apparelMod::removeFaceIndex(int faceIndex)
{
	 m_indicesFaces.erase(std::remove(m_indicesFaces.begin(), m_indicesFaces.end(), faceIndex), m_indicesFaces.end());
}

//--------------------------------------------------------------
void apparelMod::addVertexIndex(int vertexIndex)
{
	m_indicesVertex.push_back(vertexIndex);
}

//--------------------------------------------------------------
void apparelMod::removeVertexIndex(int vertexIndex)
{
	 m_indicesVertex.erase(std::remove(m_indicesVertex.begin(), m_indicesVertex.end(), vertexIndex), m_indicesVertex.end());
}


//--------------------------------------------------------------
void apparelMod::parameterChanged(ofAbstractParameter & parameter)
{
	// ofLog() << "apparelMod::parameterChanged() " << parameter.getName();
	if (mp_oscSender){
		mp_oscSender->sendParameter( parameter );
	}
}

//--------------------------------------------------------------
string apparelMod::getPathRelative(string filename)
{
	string path = "mods/"+m_id+"/";
	if (!filename.empty())
	{
		path += filename;
	}
	return path;
}

//--------------------------------------------------------------
string apparelMod::getPathDocument(string filename)
{
	#ifdef TARGET_OF_IOS
		return ofxiOSGetDocumentsDirectory() + getPathRelative(filename);
	#else
		return ofToDataPath(getPathRelative(filename));
	#endif
}


//--------------------------------------------------------------
string apparelMod::getPathResources(string filename)
{
	return ofToDataPath(getPathRelative(filename));
}

//--------------------------------------------------------------
void apparelMod::createWordsList()
{
	OFAPPLOG->begin("apparelMod::createWordsList() for instance \"" + m_id + "\"");
	
	string pathWordsList = getPathResources("wordlist.txt");
	ofFile fWordsList( pathWordsList );
	if (fWordsList.exists())
	{
		OFAPPLOG->println("- loaded 'wordlist.txt'");

		ofBuffer buffer = ofBufferFromFile(pathWordsList, false);
		m_words = ofSplitString(buffer.getText(), ",", true, true);

		string strWords="";
		string delimiter="";
		for (int i=0; i<m_words.size(); i++){
			strWords+=delimiter + m_words[i];
			delimiter=" / ";
		}

		OFAPPLOG->println("- found "+ofToString(m_words.size())+" words : " + strWords);
		
	}
	else{
		OFAPPLOG->begin("- cannot find 'wordlist.txt'");
	}


	OFAPPLOG->end();
}

//--------------------------------------------------------------
void apparelMod::createDirMod()
{
	ofDirectory dirMod( getPathDocument() );

	if (!dirMod.exists()){
		dirMod.create(true);
	}
}


//--------------------------------------------------------------
void apparelMod::loadModel()
{
	OFAPPLOG->begin("apparelMod::loadModel() for instance \"" + m_id + "\"");
	// MODEL DATA
	string pathModel = getPathResources("model.xml");
	if ( m_settingsModel.load(pathModel) )
	{
		OFAPPLOG->println("- loaded "+pathModel);

		m_indicesFaces.clear();
		
		m_settingsModel.pushTag("mod");

			m_settingsModel.pushTag("faces");
			int nbFaces = m_settingsModel.getNumTags("index");
			for (int i=0; i<nbFaces; i++)
			{
				m_indicesFaces.push_back( m_settingsModel.getValue("index",0,i) );
			}
			m_settingsModel.popTag();

			m_settingsModel.pushTag("vertices");
			int nbVertices = m_settingsModel.getNumTags("index");
			for (int i=0; i<nbVertices; i++)
			{
				m_indicesVertex.push_back( m_settingsModel.getValue("index",0,i) );
			}
			m_settingsModel.popTag();
		
			
	   m_settingsModel.popTag();
	}
	else{
		OFAPPLOG->println(OF_LOG_ERROR, "- error loading "+pathModel);
	}

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void apparelMod::saveModel()
{
	OFAPPLOG->begin("apparelMod::saveModel() for instance \"" + m_id + "\"");
	createDirMod();

	// MODEL DATA
	ofxXmlSettings settings;
	
	settings.addTag("mod");
	settings.pushTag("mod");

	settings.addTag("faces");
	settings.pushTag("faces");
	vector<int>::iterator facesIt;
	for (facesIt = m_indicesFaces.begin(); facesIt != m_indicesFaces.end(); ++facesIt)
	{
		settings.addValue("index", *facesIt);
	}
	settings.popTag();

	// Vertices
	settings.addTag("vertices");
	settings.pushTag("vertices");
	vector<int>::iterator verticesIt;
	for (verticesIt = m_indicesVertex.begin(); verticesIt != m_indicesVertex.end(); ++verticesIt)
	{
		settings.addValue("index", *verticesIt);
	}
	settings.popTag();

	settings.popTag();

	string pathModel = getPathResources("model.xml");

	OFAPPLOG->println("- saving " + pathModel );
	settings.save(pathModel);
	
	OFAPPLOG->end();
}

//--------------------------------------------------------------
void apparelMod::loadParameters()
{
	OFAPPLOG->begin("apparelMod::loadParameters() for instance \"" + m_id + "\"");

	// WORDS
	createWordsList();

	// PARAMETERS DATA
	ofxXmlSettings settingsParameters;
	string pathParameters = getPathDocument("parameters.xml");
	if (settingsParameters.load(pathParameters))
	{
		settingsParameters.deserialize(m_parameters);
		OFAPPLOG->println("- loaded "+pathParameters);
	}
	else{
		OFAPPLOG->println(OF_LOG_ERROR, "- error loading "+pathParameters);
	}

	// Custom loading
	loadParametersCustom();

	// Add listener
	ofAddListener(m_parameters.parameterChangedE, this, &apparelMod::parameterChanged);

	OFAPPLOG->end();
}

//--------------------------------------------------------------
void apparelMod::saveParameters()
{
	OFAPPLOG->begin("apparelMod::saveParameters() for instance \"" + m_id + "\"");
	createDirMod();

	// PARAMETERS DATA
	ofxXmlSettings settings;
	settings.serialize(m_parameters);
	string pathParameters = getPathDocument("parameters.xml");

	OFAPPLOG->println("- saving " + pathParameters );
	settings.save(pathParameters);

	OFAPPLOG->end();
}


//--------------------------------------------------------------
void apparelMod::setConfiguration(string name)
{
	m_configurationName = name;
}




