﻿package com.locusenergy.panels {		import flash.display.*;	import com.locusenergy.menus.*;	import com.locusenergy.charts.*;	import com.locusenergy.Connector;	import com.locusenergy.AssetCache;	import flash.events.Event;	import flash.events.MouseEvent;	import flash.utils.getDefinitionByName;			public class LiveDataPanel extends Panel{				// Constants:		// Public Properties:		// Private Properties:		private var genPanel:LiveDataGeneration;		private var consPanel:LiveDataConsVsProd;		private var stringLevelPanel:LiveDataStringLevel;		private var consumptionPanel:LiveDataConsumption;		private var netMeterStatusPanel:NetMeterStatusPanel;		private var envBenPanel:EnvironmentalBenefitsPanel;		private var currWeatherPanel:CurrentWeatherPanel;		private var currLoadPanel:CurrentLoadPanel;		private var currGenPanel:CurrentGenerationPanel;		private var recentGenPanel:RecentGenerationPanel;		private var stringLevelFlag:Boolean;		// Initialization:		public function LiveDataPanel(connector) 		{ 			this.connector = connector;			hasInternalSlideshow = true;			loadInitialPanel();			internalSSDelay();			connector.getComponentData("LiveData", setAttributes);		}		public function setAttributes()		{			for (var i=0; i < connector.resultArray[0].length; i++)			{				switch (connector.resultArray[0][i])				{					case ("stringLevelFlag")	:	stringLevelFlag = connector.resultArray[1][i];													break;				}			}			subMenu.menuItemArray[0].dispatchEvent(new MouseEvent(MouseEvent.CLICK));			dispatchEvent(new Event("TabDataLoaded"));		}		private function loadInitialPanel()		{			//trace("Load Initial Live Data Sub Menu");			loadSubMenu(0);					}		// Public Methods:		override protected function loadSubMenu(index)		{			subMenu = new Menu("SUB",index);			//subMenu.addMenuItem("GENERATION","", "com.locusenergy.panels.LiveDataGeneration");			for (var i in AssetCache.liveDataTitles)			{				//trace("Loading Live Data Menu", AssetCache.liveDataTitles[i], AssetCache.liveDataTypes[i]);				subMenu.addMenuItem(AssetCache.liveDataTitles[i],"", "com.locusenergy.panels." + AssetCache.liveDataTypes[i]);			}			for (var j in subMenu.menuItemArray)			{				subMenu.menuItemArray[j].addEventListener(MouseEvent.CLICK, itemClicked);				subMenu.menuItemArray[j].index = j;			}			this.addChild(subMenu);			subMenu.x = 640 - subMenu.width/2;			subMenu.y = 0;			trace("Live Data Menu Loaded");		}		override protected function itemClicked(me:MouseEvent)		{			trace("Live Data Item Clicked Event", me.target);						cleanUp();			var cRef:Class = getDefinitionByName(me.currentTarget.obj as String) as Class;			//if (me.currentTarget.obj  == "com.locusenergy.panels.LiveDataGeneration")			currentPanel = new cRef(this.connector, AssetCache.liveDataNodes[me.currentTarget.index]);			getPanelInfoForIndex(me.currentTarget.index)			trace("ADDING LISTENER MONITOR")			currentPanel.addEventListener("DataLoaded", callMonitorAPI, false, 0, true);			//else			//	currentPanel = new cRef();			this.addChild(currentPanel);			loadSubMenu(me.currentTarget.index);		}		override protected function getPanelInfoForIndex(index)		{			currentPanel.paramArray["nodes"] = AssetCache.liveDataNodes[index];			trace("Nodes", currentPanel.paramArray["nodes"]);		}	}	}