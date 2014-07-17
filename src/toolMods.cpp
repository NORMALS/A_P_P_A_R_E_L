//
//  toolMods.cpp
//  A_P_P_A_R_E_L
//
//  Created by Julien on 02/06/2014.
//
//

#include "toolMods.h"
#include "tool3D.h"
#include "globals.h"

//--------------------------------------------------------------
toolMods::toolMods(toolManager* parent, apparelModel* model) : tool("Mods", parent)
{
	mp_modCurrent = 0;
	mp_modUICurrent = 0;
	mp_apparelModel = model;
}

//--------------------------------------------------------------
toolMods::~toolMods()
{
}

//--------------------------------------------------------------
void toolMods::show(bool is)
{
	tool::show(is);
	if (mp_modUICurrent)
		mp_modUICurrent->show(is);
}

//--------------------------------------------------------------
bool toolMods::isHit(int x, int y)
{
	return (tool::isHit(x, y) || ( mp_modUICurrent && mp_modUICurrent->getCanvas() &&  mp_modUICurrent->getCanvas()->isHit(x,y)));
}

//--------------------------------------------------------------
void toolMods::exit()
{
	map<string, apparelMod*>::iterator it;
	for (it = m_mods.begin(); it != m_mods.end(); ++it){
		it->second->saveParameters();
		delete it->second;
	}
}

//--------------------------------------------------------------
void toolMods::addMod(apparelMod* mod)
{
	if (mod)
	{
		mod->mp_model = mp_apparelModel; // TEMP
		mod->loadParameters();
		mod->setOscSender( GLOBALS->getOscSender() );
		m_mods[mod->m_id] = mod;
	}
}

//--------------------------------------------------------------
void toolMods::createControlsCustom()
{
	vector<string> modIds;

	map<string, apparelMod*>::iterator it;
	for (it = m_mods.begin(); it != m_mods.end(); ++it)
	{
		modIds.push_back(it->second->m_id);
	}
	
	mp_canvas->addLabel("Mods");
	mp_canvas->addSpacer(300,1);
	mp_canvas->addRadio("modIds", modIds);
	mp_canvas->autoSizeToFitWidgets();
}

//--------------------------------------------------------------
void toolMods::createControlsCustomFinalize()
{
	map<string, apparelMod*>::iterator it;
	for (it = m_mods.begin(); it != m_mods.end(); ++it)
	{
		apparelModUI* modUI = makeInstanceModUI(it->second);
		if (modUI)
		{
			// Canavs position
			ofVec2f pos(
				getCanvas()->getRect()->getX() + getCanvas()->getRect()->getWidth()+10,
				getCanvas()->getRect()->getY()
			);
			
			// Create controls
			modUI->createControls( pos );
			
			// Save in map
			m_modsUI[it->first] = modUI;
			
		}
	}
}

//--------------------------------------------------------------
void toolMods::handleEvents(ofxUIEventArgs& e)
{
    string name = e.widget->getName();
	if (name == "modIds")
	{
        ofxUIRadio *radio = (ofxUIRadio *) e.widget;
		selectMod( radio->getActiveName() );
	}
}

//--------------------------------------------------------------
apparelModUI* toolMods::makeInstanceModUI(apparelMod* mod)
{
	return new apparelModUI(mod);
}


//--------------------------------------------------------------
void toolMods::selectMod(string name)
{

	// Show UI
	map<string, apparelModUI*>::iterator it;
	for (it = m_modsUI.begin(); it != m_modsUI.end(); ++it){
		it->second->hide();
	}

	// Select mod
	mp_modCurrent = m_mods[name];

	// Select mod UI
	mp_modUICurrent = m_modsUI[name];
	if (mp_modUICurrent)
		mp_modUICurrent->show();
	
	// Inform other tool
	if (mp_toolManager) {
		tool3D* pTool3D = (tool3D*) mp_toolManager->getTool("3D");
		if (pTool3D)
			pTool3D->onSelectMod(mp_modCurrent);
	}
}

