﻿package com.locusenergy.panels {		import flash.display.*;	import flash.events.*;		public class CurrentLoadPanel extends Panel {				// Constants:		// Public Properties:		// Private Properties:		private var loadPanel:CurrentLoadGenPanel;		// Initialization:		public function CurrentLoadPanel(connector, nodes='all') { 			loadPanel = new CurrentLoadGenPanel(connector, "CurrentLoad", nodes);			loadPanel.addEventListener("DataLoaded",	dispatchLoaded, false, 0, true);			addChild(loadPanel);		}		override public function cleanUp()		{			removeChild(loadPanel);			if (loadPanel.hasEventListener("DataLoaded"))				loadPanel.removeEventListener("DataLoaded", dispatchLoaded);			loadPanel.cleanUp();		}		private function dispatchLoaded(e)		{			dispatchEvent(new Event("DataLoaded"));		}		// Public Methods:		// Protected Methods:	}	}