﻿package com.locusenergy.modules {		import com.locusenergy.Connector;	import flash.events.Event;	import flash.text.TextField;	import flash.text.TextFormat;	import flash.text.AntiAliasType;	import flash.net.Responder;		public class SystemSummaryModule extends KioskModule{				// Constants:		// Public Properties:		// Private Properties:		private var size:TextField = new TextField();		private var panelType:TextField = new TextField();		private var inverterType:TextField = new TextField();		private var sizeLabel:TextField = new TextField();		private var panelTypeLabel:TextField = new TextField();		private var inverterTypeLabel:TextField = new TextField();		// Initialization:		public function SystemSummaryModule() 		{			addChild(shadowBox);			setupReadout();			componentName =	"SystemSummary";		}		public function setupReadout()		{			var textFormat:TextFormat = new TextFormat("Gotham Narrow Light", 12, 0xffffff);			var vertSpacing = 26;			var labelXPos = 72;			var readoutXPos = labelXPos + 441;			var startY = 93;						addChild(sizeLabel);			addChild(panelTypeLabel);			addChild(inverterTypeLabel);						addChild(size);			addChild(panelType);						addChild(inverterType);									sizeLabel.antiAliasType = AntiAliasType.ADVANCED;			size.antiAliasType = AntiAliasType.ADVANCED;			panelTypeLabel.antiAliasType = AntiAliasType.ADVANCED;			panelType.antiAliasType = AntiAliasType.ADVANCED;			inverterTypeLabel.antiAliasType = AntiAliasType.ADVANCED;			inverterType.antiAliasType = AntiAliasType.ADVANCED;						sizeLabel.x = labelXPos;			panelTypeLabel.x = labelXPos;			inverterTypeLabel.x = labelXPos;						sizeLabel.embedFonts = true;			panelTypeLabel.embedFonts = true;			inverterTypeLabel.embedFonts = true;			sizeLabel.defaultTextFormat = textFormat;			panelTypeLabel.defaultTextFormat = textFormat;			inverterTypeLabel.defaultTextFormat = textFormat;			sizeLabel.autoSize = "left";			panelTypeLabel.autoSize = "left";			inverterTypeLabel.autoSize = "left";						textFormat = new TextFormat("Gotham Narrow Book", 14, 0xFFC900);			size.embedFonts = true;			panelType.embedFonts = true;			inverterType.embedFonts = true;			size.defaultTextFormat = textFormat;			panelType.defaultTextFormat = textFormat;			inverterType.defaultTextFormat = textFormat;			size.autoSize = "right";			panelType.autoSize = "right";			inverterType.autoSize = "right";									size.x = readoutXPos;			panelType.x = readoutXPos;			inverterType.x = readoutXPos;			this.graphics.lineStyle(1, 0xFFFFFF, 0.1);			this.graphics.moveTo(labelXPos, startY + 20);			this.graphics.lineTo(readoutXPos, startY + 20);						sizeLabel.y = startY;			size.y = startY;			panelTypeLabel.y = size.y + vertSpacing;			panelType.y = size.y + vertSpacing;			inverterTypeLabel.y = panelType.y + vertSpacing;			inverterType.y = panelType.y + vertSpacing;									this.graphics.moveTo(labelXPos, size.y + vertSpacing + 20);			this.graphics.lineTo(readoutXPos, size.y + vertSpacing + 20);			this.graphics.moveTo(labelXPos, inverterType.y + 20);			this.graphics.lineTo(readoutXPos, inverterType.y + 20);						sizeLabel.text = "SIZE";			panelTypeLabel.text = "PANEL TYPE";						inverterTypeLabel.text = "INVERTER TYPE";					}		override protected function loadData()		{			for (var i in connector.resultArray[0])			{				switch (connector.resultArray[0][i].toString())				{					case "size" 			:	size.text = connector.resultArray[1][i] + " kW";												break;					case "panelType" 		:	panelType.text = connector.resultArray[1][i];												break;					case "inverterType" 	:	inverterType.text = connector.resultArray[1][i];												break;																	}			}			dispatchEvent(new Event("DataLoaded"));		}	}	}