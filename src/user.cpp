//
//  user.cpp
//  A_P_P_A_R_E_L
//
//  Created by Julien on 16/07/2014.
//
//

#include "user.h"
#include "userSocialFactory.h"
#include "ofAppLog.h"

user::~user()
{
	vector<userSocialInterface*>::iterator it;
	for (it = m_listSocialInterfaces.begin() ; it != m_listSocialInterfaces.end() ; ++it)
		delete *it;
	m_listSocialInterfaces.clear();
}


void user::loadConfiguration()
{
	OFAPPLOG->begin("user::loadConfiguration()");

	string pathFile = getPath("configuration.xml");
	OFAPPLOG->println("- loading file " + pathFile);

	if (m_configuration.load(pathFile))
	{
		OFAPPLOG->println("- loaded file");

		// Services factory
		int nbServices = m_configuration.getNumTags("user:services");
		OFAPPLOG->println("- found "+ofToString(nbServices)+" service(s)");
	
		for (int i=0; i<nbServices; i++)
		{
			// Info into the xml configuration file
			userConfigurationInfo* pUserConfigInfo = new userConfigurationInfo(this, "user:service", i);

			// Create instance with factory
			userSocialInterface* pSocialInterface = userSocialFactory::makeInstance(pUserConfigInfo);

			// Push in list
			if (pSocialInterface){
				m_listSocialInterfaces.push_back(pSocialInterface);
			}
		
			// Delete info
			delete pUserConfigInfo;
		}

	}
	else
	{
		OFAPPLOG->println(OF_LOG_ERROR, "-error loading file");
	}
	
	OFAPPLOG->end();
}

void user::update()
{
	vector<userSocialInterface*>::iterator it;
	for (it = m_listSocialInterfaces.begin() ; it != m_listSocialInterfaces.end(); ++it){
		(*it)->update();
	}
	
}



