﻿package com.locusenergy.panels {		import caurina.transitions.Tweener;	import com.locusenergy.menus.*;	import com.locusenergy.AssetCache;	import com.locusenergy.meters.*;	import com.locusenergy.AssetLoader;	import com.locusenergy.ShadowBox;	import com.locusenergy.modules.NetMeterStatusModule;	import com.locusenergy.Connector;	import flash.display.*;	import flash.events.Event;	import flash.events.EventDispatcher;	import flash.events.TimerEvent;	import flash.events.MouseEvent;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.AntiAliasType;	import flash.filters.DropShadowFilter;	import flash.geom.Point;	import flash.filters.GlowFilter;	import flash.utils.Timer;		public class HowItWorksPanel extends Panel{				// Constants:		// Public Properties:		// Private Properties:		private var maxTime = 5;		private var sunHIW:HIWobject;		private var invertersHIW:HIWobject;		private var pvModulesHIW:HIWobject;		private var meterBlockHIW:HIWobject;		private var theGridHIW:HIWobject;		private var shadowBox:ShadowBox;		private var module:NetMeterStatusModule;		private var anaMeter1;		private var anaMeter2;		private var digiMeter;		private var objectArray:Array;		private var animationPath:Array;		private var sparkArray:Array;		private var revSparkArray:Array;		private var glowFilter:GlowFilter;		private var meterOutput1:MeterOutput = new MeterOutput();		private var meterOutput2:MeterOutput = new MeterOutput();		private var meterOutput3:MeterOutput = new MeterOutput();		private var meterOutput4:MeterOutput = new MeterOutput();		private var HIWconnector:Connector;		private var sparkCount:int = 1;		private var sparkSpeed:Number = 0;		private var sparkContainer:Sprite;		private var pvText:String = new String();		private var solarText:String = new String();		private var metersText:String = new String();		private var theGridText:String = new String();		private var invertersText:String = new String();		private var pvSprite:Sprite = new Sprite();		private var meterUpdateFlag = false;		private var microinvertersFlag = false;		private var partialMeterFlag = false;		// Initialization:		public function HowItWorksPanel(connector) 		{ 						HIWconnector = connector;			module = new NetMeterStatusModule(true);			hasInternalSlideshow = true;						loadAssets();			internalSSDelay();		}		public function loadAssets()		{/*			trace("HIW", AssetCache.howItWorksSWF.getChildByName("horizon_mc"));			var sp:Sprite = AssetCache.howItWorksSWF;*/			addChild(AssetCache.horizon);			objectArray = new Array();			sunHIW =  new HIWobject(AssetCache.sunHIW);			objectArray.push(sunHIW);			pvModulesHIW = new HIWobject(pvSprite);			objectArray.push(pvModulesHIW);			if (AssetCache.showMicroinverters)				invertersHIW = new HIWobject(AssetCache.microinvertersHIW);			else				invertersHIW = new HIWobject(AssetCache.invertersHIW);							objectArray.push(invertersHIW);			meterBlockHIW = new HIWobject(AssetCache.meterBlockHIW);			objectArray.push(meterBlockHIW);			theGridHIW = new HIWobject(AssetCache.gridHIW);			objectArray.push(theGridHIW);									sparkContainer = new Sprite();			addChild(sparkContainer);			loadText();			setAnimPath();			displayArc();			addChild(drawPath(0.3));			addChild(sunHIW);			addChild(pvModulesHIW);			addChild(invertersHIW);			addChild(meterBlockHIW);			addChild(theGridHIW);						pvLoad(AssetCache.pvImage);						for (var i=0; i<objectArray.length; i++)			{				objectArray[i].sprite.addEventListener(MouseEvent.CLICK, clickEvent, false, 0, true);			}			initializeMeters();		}		private function initializeMeters()		{			anaMeter1 = new AnalogMeter();			anaMeter1.initializeExternal();			anaMeter2 = new AnalogMeter();			anaMeter2.initializeExternal();			digiMeter = new DigitalMeter(1234);			digiMeter.initializeExternal();			//anaMeter2.addEventListener("MeterLoaded", setMeterUpdateFlag, false, 0, true);			setMeterUpdateFlag(null);						meterOutput1 = new MeterOutput("INSTANTANEOUS POWER","kW", false);			meterOutput2 = new MeterOutput("GENERATED TO DATE","kWh", false);			meterOutput3 = new MeterOutput("LOAD","kW", false);			meterOutput4 = new MeterOutput("NET","kW", false);		}				////////////////		private function setMeterUpdateFlag(e)		{			anaMeter2.removeEventListener("MeterLoaded", setMeterUpdateFlag);			meterUpdateFlag = true;						solarResources(new MouseEvent("me"));			HIWconnector.getComponentData("HowItWorks", getHIWData);		}		private function getHIWData()		{			var pvURL:String;			for (var i in HIWconnector.resultArray[0])			{				switch (HIWconnector.resultArray[0][i])				{					case "sparkCount":			sparkCount = HIWconnector.resultArray[1][i];												break;					case "sparkSpeed":			sparkSpeed = HIWconnector.resultArray[1][i];												break;					case "solarText":			AssetCache.solarTextHIW = HIWconnector.resultArray[1][i];												bodyText.htmlText = AssetCache.solarTextHIW;												break;					case "pvText":				AssetCache.pvTextHIW = HIWconnector.resultArray[1][i];												break;						case "metersText":			AssetCache.meterTextHIW = HIWconnector.resultArray[1][i];												break;						case "theGridText":			AssetCache.gridTextHIW = HIWconnector.resultArray[1][i];												break;						case "invertersText":		AssetCache.inverterTextHIW = HIWconnector.resultArray[1][i];												break;					case "fullMeterFlag":		partialMeterFlag = !HIWconnector.resultArray[1][i];												break;				}			}			//solarResources(new MouseEvent("me"));			loadMeters();			maxTime = maxTime/sparkSpeed;			animation();			reverseAnimation();			loadModuleData();			//dispatchEvent(new Event("startInternalSlideshow"));			dispatchEvent(new Event("TabDataLoaded"));					}		private function loadModuleData()		{			module.addEventListener("DataLoaded", loadMeterData, false, 0, true);			module.getModuleData(HIWconnector);		}		public function pvLoad(sp:Sprite)		{			pvModulesHIW.sprite.addChild(sp);			pvModulesHIW.y = this.height - pvModulesHIW.sprite.height - 30;			pvModulesHIW.x = 580 - pvModulesHIW.sprite.width;		}		public function loadMeterData(e)		{			trace("Load Meter Data Here");			module.removeEventListener("DataLoaded", loadMeterData);			module.addEventListener("ModuleUpdated", updateMeterOutput, false, 0, true);			updateMeterOutput(null);			module.poll();		}		public function loadMeters()		{			trace("LOADING METERS");			addMeterOutputs();			meterBlockHIW.sprite.addChild(anaMeter1);			meterBlockHIW.sprite.addChild(anaMeter2);			meterBlockHIW.sprite.addChild(digiMeter);			if (partialMeterFlag)			{				anaMeter1.x = -75;				anaMeter1.y = -40;				digiMeter.x = -3;				digiMeter.y = -40;				anaMeter2.alpha = 0;												anaMeter1.scaleX = .4;				anaMeter1.scaleY = .4;				digiMeter.scaleX = .4;				digiMeter.scaleY = .4;			}			else			{				anaMeter1.x = -75;				anaMeter1.y = -20;				anaMeter2.x = -30;				anaMeter2.y = -45;				digiMeter.x = 15;				digiMeter.y = -20;								anaMeter1.scaleX = .3;				anaMeter1.scaleY = .3;				anaMeter2.scaleX = .3;				anaMeter2.scaleY = .3;				digiMeter.scaleX = .3;				digiMeter.scaleY = .3;			}					}		public function addMeterOutputs()		{			meterOutput1.x = 566; //meterBlockHIW.sprite.x - 270;			meterOutput1.y = 295; //meterBlockHIW.sprite.y - 35;						if (partialMeterFlag)			{				meterOutput2.x = 876 //meterBlockHIW.sprite.x + 40;				meterOutput2.y = 295; //meterBlockHIW.sprite.y - 35;				meterOutput3.alpha = 0;				meterOutput4.alpha = 0;			}			else			{				meterOutput2.x = 726; //meterBlockHIW.sprite.x - 110;				meterOutput2.y = 215; //meterBlockHIW.sprite.y - 115;				meterOutput3.x = 876 //meterBlockHIW.sprite.x + 40;				meterOutput3.y = 295; //meterBlockHIW.sprite.y - 35;				meterOutput4.x = 736; //meterBlockHIW.sprite.x - 100;				meterOutput4.y = 375; //meterBlockHIW.sprite.y + 45;						}			addChild(meterOutput1);			addChild(meterOutput2);			addChild(meterOutput3);			addChild(meterOutput4);		}		private function updateMeterOutput(e)		{			trace("Update Meter Output Here", meterOutput1, meterOutput2, meterOutput3, meterOutput4);			if(meterOutput1 != null) meterOutput1.updateMeter(module.instPower);			if(meterOutput2 != null) meterOutput2.updateMeter(module.powerGen);			if(meterOutput3 != null) meterOutput3.updateMeter(module.load);			if(meterOutput4 != null) meterOutput4.updateMeter(module.net);			updateMeter();		}		private function updateMeter() 		{			trace("Updating Meter", meterUpdateFlag, anaMeter1, anaMeter2);			if(meterUpdateFlag)			{				if (anaMeter1 != null)				{					anaMeter1.setMax(module.instPowerMaxValue);					anaMeter1.setMeterReading(module.instPower);				}				if (anaMeter2 != null)				{					anaMeter2.setMax(module.loadMaxValue);					anaMeter2.setMeterReading(module.load);				}			}			trace("Meter Updated");		}		public function loadText()		{			var format:TextFormat = new TextFormat("Gotham Narrow Book", 14, 0xFFFFFF);			format.leading = 5;			bodyText.defaultTextFormat = format;			bodyText.width = 210;			bodyText.antiAliasType = AntiAliasType.ADVANCED;			bodyText.height = 400;			bodyText.y = 155;			bodyText.x = 50;						shadowBox = new ShadowBox(235, 250);			addChild(shadowBox);			shadowBox.x = 30;			shadowBox.y = 135;						titleText.y = 85;			titleText.x = 30;			addChild(titleText);			addChild(bodyText);		}		public function setAnimPath()		{			//set animation Path			animationPath = new Array();						var startPoint:Point = new Point(sunHIW.sprite.x, sunHIW.sprite.y + 10);			animationPath.push(startPoint);									//0			var nextPoint:Point = new Point(startPoint.x, 225);			animationPath.push(nextPoint);									//1			nextPoint = new Point(startPoint.x - 60, 225);			animationPath.push(nextPoint);									//2						nextPoint = new Point(startPoint.x - 60, 495);			animationPath.push(nextPoint);									//3			nextPoint = new Point(startPoint.x + 140, 495);			animationPath.push(nextPoint);									//4			nextPoint = new Point(startPoint.x + 140, 355);			animationPath.push(nextPoint);									//5			nextPoint = new Point(startPoint.x + 300, 355);			animationPath.push(nextPoint);									//6			nextPoint = new Point(startPoint.x + 460, 355);			animationPath.push(nextPoint);									//7			nextPoint = new Point(startPoint.x + 460, 405);			animationPath.push(nextPoint);									//8			nextPoint = new Point(startPoint.x + 600, 405);			animationPath.push(nextPoint);									//9		}				public function displayArc()		{			var dashedLines = new Sprite();						var dashed = new DashedLine(dashedLines, 2, 4);			dashed.lineStyle(2,0xFFFFFF,0.7);			dashed.moveTo(shadowBox.x + shadowBox.width,175);			dashed.curveTo(700, -5, 1280, 275);			addChild(dashedLines);		}				public function drawPath(alfa):Sprite		{			//draw lines along animation path			var dashedLines = new Sprite();						var dashed = new DashedLine(dashedLines, 10, 13);			dashed.moveTo(animationPath[0].x, animationPath[0].y);			for (var i=1 in animationPath)			{				if (i == 6 || i == 7)					dashed.lineStyle(2, 0xFFFFFF, 0);				else					dashed.lineStyle(2, 0xFFFFFF, alfa);				dashed.lineTo(animationPath[i].x, animationPath[i].y);			}			return dashedLines;		}			public function drawSpark(color1, color2):Sprite		{			var spark:Sprite = new Sprite();			spark.graphics.beginFill(color1, 0.6);			spark.graphics.drawCircle(0, 0, 6);			spark.x = sunHIW.sprite.x;			spark.y = sunHIW.sprite.y;			spark.graphics.endFill();			glowFilter = new GlowFilter(color2, 0.8 , 15, 15, 9, 6, false);			spark.filters = [glowFilter];			return spark;					}				/***********Forward Spark Animation**************/		public function animation()		{			sparkArray = new Array();			fillSparkArray();			beginAnimation();		}		public function fillSparkArray()		{			for (var i = 0; i < sparkCount; i++)			{				sparkArray.push(drawSpark(0xffdd2a, 0xff9f12));				sparkArray[i].alpha = 0;				sparkContainer.addChild(sparkArray[i]);					}		}		public function beginAnimation()		{			for (var j in sparkArray)			{				animateSpark(j);			}		}		public function animateSpark(j)		{			var sparkDelay = maxTime * .3;			var futDelay = 0;			var endPt;						if (module.net < 0)			{				endPt = 10;			}			else			{				endPt = 7;			}			var func:Function = null;			for(var i=1; i < endPt; i++)			{				var delay = futDelay + sparkDelay*j;				var alfa = 1;				var t = distanceCalc(animationPath[i], animationPath[i-1])/320 * maxTime;				if (i == endPt-1)					func = resetSpark;				if (module.instPower == 0)				{					(sparkArray[j] as Sprite).alpha = 0;					alfa = 0;				}				Tweener.addTween(sparkArray[j], {alpha: alfa, x: animationPath[i].x, y:animationPath[i].y, delay:delay, time: t, transition: "linear", onComplete:func, onCompleteParams: [j]});				futDelay = futDelay + t;			}		}		public function resetSpark(j)		{			sparkArray[j].x = sunHIW.sprite.x;			sparkArray[j].y = sunHIW.sprite.y;			sparkArray[j].alpha = 0;			if (j == sparkArray.length -1)				beginAnimation();		}				/***********Reverse Spark Animation**************/		public function reverseAnimation()		{			revSparkArray = new Array();			fillReverseSparkArray();			beginReverseAnimation();		}				public function fillReverseSparkArray()		{			for (var i = 0; i < sparkCount - 1; i++)			{				revSparkArray.push(drawSpark(0xff0000, 0xfc3004));				sparkContainer.addChild(revSparkArray[i]);				revSparkArray[i].x = animationPath[animationPath.length -1]. x;				revSparkArray[i].y =  animationPath[animationPath.length -1].y;				revSparkArray[i].alpha = 0;			}		}		public function beginReverseAnimation()		{			for (var j in revSparkArray)			{				animateReverseSpark(j);							}		}		public function animateReverseSpark(j)		{			var sparkDelay = maxTime * 0.5;			var futDelay = 0;			var endPt = 6;						var func:Function = null;			for(var i = animationPath.length -1; i > endPt; i--)			{				var delay = futDelay + sparkDelay*j;				var alfa = 1;				var t = distanceCalc(animationPath[i], animationPath[i-1])/320 * maxTime;				if (i == endPt+1)					func = resetReverseSpark;				if (module.net <= 0 || partialMeterFlag)				{					(revSparkArray[j] as Sprite).alpha = 0;					alfa = 0;				}									Tweener.addTween(revSparkArray[j], {alpha:alfa, x: animationPath[i-1].x, y:animationPath[i-1].y, delay:delay, time: t, transition: "linear", onComplete:func, onCompleteParams: [j]});				futDelay = futDelay + t;			}		}		public function resetReverseSpark(j)		{			revSparkArray[j].x = animationPath[animationPath.length - 1].x;			revSparkArray[j].y = animationPath[animationPath.length -1 ].y;			revSparkArray[j].alpha = 0;			if (j == revSparkArray.length -1)				beginReverseAnimation();		}		public function hitTest(evt:Event)		{			/*if (spark.hitTestObject(pvModulesHIW))			{				pvModulesHIW.highlightIntense(0.25,0.03);			}			else if (spark.hitTestObject(meterBlockHIW))			{				meterBlockHIW.highlightIntense(0.25,0);			}			else if (spark.hitTestObject(invertersHIW))			{				invertersHIW.highlightIntense(0.3,0);			}			else if (spark.hitTestObject(theGridHIW))			{				theGridHIW.highlightIntense(0.4,0);			}*//*			if (spark.hitTestObject(meterBlockHIW))			{				meterBlockHIW.highlightIntense(0.3,0);				var t = distanceCalc(animationPath[8], animationPath[7])/320 * maxTime;				Tweener.addTween(spark2, {x: animationPath[7].x, y:animationPath[7].y, time: t, transition: "linear", onComplete:resetSpark});			}*/		}				static function distanceCalc(pt1:Point, pt2:Point):Number		{			var dist:Number;			//this simple calc works because we are not moving in diagonals			dist = Math.abs(pt2.x - pt1.x);			dist = dist + Math.abs(pt2.y - pt1.y);						return dist;		}		public function clickEvent(evt: MouseEvent)		{			unhighlightAll(evt.currentTarget as Sprite);			for (var i=0 in objectArray)			{				if (objectArray[i].sprite == evt.currentTarget) subMenu.menuItemArray[i].dispatchEvent(new MouseEvent(MouseEvent.CLICK));			}		}		public function unhighlightAll(sp:Sprite)		{			//unhighlight everything except the selected			for (var i=0; i<objectArray.length; i++)			{				if (objectArray[i].sprite != sp)				{					objectArray[i].unhighlight();				}				else				{					//removeChild(subMenu);				}			}					}		public function solarResources(me:MouseEvent)		{			loadSubMenu(0);			titleText.text = "Solar Resource";			bodyText.htmlText = AssetCache.solarTextHIW;			unhighlightAll(null);			sunHIW.highlight();		}		public function pvModules(me:MouseEvent)		{			loadSubMenu(1);			titleText.text = "PV Modules";			bodyText.htmlText = AssetCache.pvTextHIW;			unhighlightAll(null);			pvModulesHIW.highlight();					}		public function inverters(me:MouseEvent){			loadSubMenu(2);			titleText.text = "Inverters";			bodyText.htmlText = AssetCache.inverterTextHIW;			unhighlightAll(null);			invertersHIW.highlight();			}		public function measurement(me:MouseEvent){			loadSubMenu(3);			titleText.text = "Measurement";			bodyText.htmlText = AssetCache.meterTextHIW;			unhighlightAll(null);			meterBlockHIW.highlight();			}		public function theGrid(me:MouseEvent){			loadSubMenu(4);			titleText.text = "The Grid";			bodyText.htmlText = AssetCache.gridTextHIW;			unhighlightAll(null);			theGridHIW.highlight();			}		override protected function itemClicked(me:MouseEvent)		{			cleanUpSubMenu();			this[me.currentTarget.obj as String](me);		}		override protected function loadSubMenu(index)		{			subMenu = new Menu("SUB",index);			subMenu.addMenuItem("SOLAR RESOURCES","","solarResources");			subMenu.addMenuItem("PV MODULES","","pvModules");			subMenu.addMenuItem("INVERTER(S)","","inverters");			subMenu.addMenuItem("MEASUREMENT","","measurement");			subMenu.addMenuItem("THE GRID","","theGrid");						for (var i=0 in subMenu.menuItemArray)			{				subMenu.menuItemArray[i].addEventListener(MouseEvent.CLICK, itemClicked, false, 0, true);				subMenu.menuItemArray[i].index = i;			}			this.addChild(subMenu);			dispatchEvent(new Event("MenuLoaded"));			subMenu.x = 640 - subMenu.width/2;			subMenu.y = 0;		}		override protected function removeAdditionalEventHandlers()		{			if (objectArray != null)			{				for (var i=0; i<objectArray.length; i++)				{					if (objectArray[i].hasEventListener(MouseEvent.CLICK))					{						trace("Removing event listener", i);						objectArray[i].sprite.removeEventListener(MouseEvent.CLICK, clickEvent);					}					objectArray[i].cleanUp();					removeChild(objectArray[i]);				}			}				if (module != null)			{				if (module.hasEventListener("ModuleUpdated"))					module.removeEventListener("ModuleUpdated", updateMeterOutput);				if (module.hasEventListener("DataLoaded"))					module.removeEventListener("DataLoaded", loadMeterData);				module.cleanUp();			}			Tweener.removeAllTweens();			}		private function cleanUpSubMenu()		{			removeMenuEventHandlers();		}	}}