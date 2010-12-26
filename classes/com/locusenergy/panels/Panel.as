﻿package com.locusenergy.panels {		import flash.display.Sprite;	import com.locusenergy.Connector;	import com.locusenergy.menus.Menu;	import com.locusenergy.AssetCache;	import com.locusenergy.KioskMonitor;	import caurina.transitions.Tweener;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.AntiAliasType;	import flash.filters.DropShadowFilter;	import flash.utils.Timer;	import flash.events.Event;		import flash.events.TimerEvent;	import flash.events.MouseEvent;	import flash.utils.getDefinitionByName;			public class Panel extends Sprite{				// Constants:		// Public Properties:		// Private Properties:		public var hasInternalSlideshow:Boolean = false;		public var titleText:TextField;		public var bodyText:TextField;		public var sideMenu:Menu;		public var paramArray;				protected var slideshowTimer;		protected var slideshowIndex;		protected var subSlideshowDone:Boolean = false;		protected var subMenu:Menu;		protected var currentPanel;		protected var slideshowSpeed;		protected var connector:Connector;		protected var timer:Timer;		protected var internalSlideshowDelayStart:Timer;				public var timerInterval:Number = AssetCache.refreshSpeed;		public var info:TextField = new TextField();		// Initialization:		public function Panel() {			//this.connector = connector;			paramArray = new Array();			setTextDefaults();			info = new TextField();			info.alpha = 0;			addChild(info);					}		protected function internalSSDelay()		{			//Used to delay dispatching event for internal slideshow start for modules that don't need to load data			internalSlideshowDelayStart = new Timer(100);			internalSlideshowDelayStart.addEventListener(TimerEvent.TIMER, startInternalSS,false, 0, true);			internalSlideshowDelayStart.start();		}		private function startInternalSS(event)		{			internalSlideshowDelayStart.stop();			internalSlideshowDelayStart.removeEventListener(TimerEvent.TIMER, startInternalSS);			dispatchEvent(new Event("startInternalSlideshow"));			additionalCalls();		}		protected function additionalCalls(){};		private function setTextDefaults()		{			this.graphics.beginFill(0xffffff, 0.2);			this.graphics.endFill();			this.y = 162;						titleText = new TextField();			bodyText = new TextField();						var format = new TextFormat("Gotham Narrow Book",30, 0xFFFFFF);			titleText.defaultTextFormat = format;			titleText.y = 60;			titleText.x = 30;			titleText.autoSize = "left";			titleText.antiAliasType = AntiAliasType.ADVANCED;			titleText.embedFonts = true;			titleText.alpha = 0.9;						var dropShadow:DropShadowFilter = new DropShadowFilter();			dropShadow.alpha = 0.6;			dropShadow.blurX = 12;			dropShadow.blurY = 12;						titleText.filters = new Array(dropShadow);									format = new TextFormat("Gotham Narrow Book", 18, 0xFFFFFF);			format.leading = 5;			bodyText.defaultTextFormat = format;			bodyText.selectable = false;			bodyText.wordWrap = true;			bodyText.embedFonts = true;			bodyText.antiAliasType = AntiAliasType.ADVANCED;			bodyText.multiline = true;			bodyText.autoSize = "left";			bodyText.x = 50;			bodyText.y = 120;		}		public function startSlideshow(speed)		{			trace ("Starting Internal Slideshow - Panel");			slideshowSpeed = speed;			slideshowTimer = new Timer(speed * 1000);			slideshowTimer.addEventListener(TimerEvent.TIMER, slideshowRotate, false, 0, true);			slideshowTimer.start();			slideshowIndex = 0;			//Don't rotate slideshow on first slide			//slideshowRotate(new Event("START"));					}		protected function slideshowRotate(e)		{			if (currentPanel != null && currentPanel.hasInternalSlideshow && !subSlideshowDone)			{				trace("Internal Rotate called from Panel", slideshowIndex);				subSlideshowDone = false;				slideshowTimer.stop();					//slideshowTimer.removeEventListener(TimerEvent.TIMER, slideshowRotate);				currentPanel.addEventListener("SubSlideshowDone", slideshowRestart, false, 0, true);				currentPanel.startSlideshow(slideshowSpeed);				currentPanel.slideshowRotate(new Event("START"));			}			else			{				subSlideshowDone = false;				slideshowIndex = slideshowIndex + 1;				trace("Rotate called", slideshowIndex);				if (slideshowIndex < subMenu.menuItemArray.length)				{					if(slideshowIndex > 0) //The first slide will already be loaded by default						subMenu.menuItemArray[slideshowIndex].dispatchEvent(new MouseEvent(MouseEvent.CLICK));									}				else				{					stopSlideshow(e);					trace("SlideshowDone");					dispatchEvent(new Event("SubSlideshowDone"));				}			}		}		protected function slideshowRestart(e)		{			subSlideshowDone = true;			currentPanel.removeEventListener("SubSlideshowDone", slideshowRestart);			slideshowTimer.start();			slideshowRotate(e);		}		public function stopSlideshow(e)		{			slideshowTimer.stop();			if (slideshowTimer.hasEventListener(TimerEvent.TIMER))	slideshowTimer.removeEventListener(TimerEvent.TIMER, slideshowRotate);			if (currentPanel != null && currentPanel.hasInternalSlideshow)	currentPanel.stopSlideshow(e);		}		public function cleanUp()		{			removeMenuEventHandlers();			removeAdditionalEventHandlers();			removeAllChildren();			cleanUpTimer();		}		public function removeMenuEventHandlers()		{			if (currentPanel != null && currentPanel.hasEventListener("DataLoaded")) currentPanel.removeEventListener("DataLoaded", callMonitorAPI);			if (subMenu != null)				for(var i = 0; i < subMenu.menuItemArray.length; i++)				{					if (subMenu.hasEventListener(MouseEvent.CLICK))						subMenu.menuItemArray[i].removeEventListener(MouseEvent.CLICK, itemClicked);				}			if (subMenu != null)				removeChild(subMenu);		}		public function removeAllChildren()		{		while (this.numChildren) 			{				//trace ("removing child", this.getChildAt(0));				if(this.getChildAt(0) is Panel)				{					//trace("Cleaning up Panel",this.getChildAt(0));					(this.getChildAt(0) as Panel).cleanUp();				}				//loop through and call cleanUp				if (this.getChildAt(0) != null)				    this.removeChildAt(0);			}		}		protected function itemClicked(me:MouseEvent)		{			cleanUp();			var cRef:Class = getDefinitionByName(me.currentTarget.obj as String) as Class;			//if (me.currentTarget.obj  == "com.locusenergy.panels.LiveDataGeneration")			currentPanel = new cRef(this.connector);			getPanelInfoForIndex(me.currentTarget.index);			currentPanel.addEventListener("DataLoaded", callMonitorAPI, false, 0, true);			//else			//	currentPanel = new cRef();			this.addChild(currentPanel);						loadSubMenu(me.currentTarget.index);		}		protected function getPanelInfoForIndex(index){}		protected function poll()		{			trace(this.name + "Panel Polling" + timerInterval, AssetCache.refreshSpeed);			timer = new Timer(timerInterval);			timer.addEventListener(TimerEvent.TIMER, liveUpdate, false, 0, true);			timer.start();		}		protected function cleanUpTimer()		{			if (timer != null)			{				if (timer.running)					timer.stop();				if (timer.hasEventListener(TimerEvent.TIMER))					timer.removeEventListener(TimerEvent.TIMER, liveUpdate);				if (timer.hasEventListener(TimerEvent.TIMER))					timer.removeEventListener(TimerEvent.TIMER, callMonitorAPI);				}		}		protected function liveUpdate(e){}		protected function loadSubMenu(index){}		protected function removeAdditionalEventHandlers(){}		protected function callMonitorAPI(e)		{			KioskMonitor.fullscreenMode = this.stage.displayState;			KioskMonitor.reportStatus();		}	}	}