﻿package com.locusenergy.modules {		import com.locusenergy.Connector;	import flash.text.*;	import flash.display.Sprite;	import flash.events.Event;	import flash.events.EventDispatcher;		public class NewsModule extends KioskModule{				// Constants:		// Public Properties:		// Private Properties:		private var newsTitle:String;		private var date:String;		private var message:String;			// Initialization:		public function NewsModule() 		{			addChild(shadowBox);			componentName = "News";		}		override protected function loadData()		{			for (var i in connector.resultArray[0])			{				switch(connector.resultArray[0][i])				{					case	"title"		:	newsTitle = connector.resultArray[1][i];											break;					case	"date"		:	date = connector.resultArray[1][i];											break;					case	"message"	:	message = connector.resultArray[1][i];											break;															}			}			fillNews();			dispatchEvent(new Event("DataLoaded"));		}				private function fillNews()		{			var newsStory:Sprite = new Sprite();			var titleTextField = new TextField();			var dateTextField = new TextField();			var messageTextField = new TextField();			var textFormat:TextFormat;						titleTextField.embedFonts = true;			dateTextField.embedFonts = true;			messageTextField.embedFonts = true;			titleTextField.antiAliasType = AntiAliasType.ADVANCED;			dateTextField.antiAliasType = AntiAliasType.ADVANCED;			messageTextField.antiAliasType = AntiAliasType.ADVANCED;			titleTextField.autoSize = TextFieldAutoSize.LEFT;			dateTextField.autoSize = TextFieldAutoSize.LEFT;			messageTextField.autoSize = TextFieldAutoSize.LEFT;						messageTextField.width = 515;			messageTextField.wordWrap = true;						textFormat = new TextFormat("Gotham Narrow Book", 18, 0xffffff);			titleTextField.defaultTextFormat = textFormat;						textFormat = new TextFormat("Gotham Narrow Book", 12, 0xFBA000);			dateTextField.defaultTextFormat = textFormat;						textFormat = new TextFormat("Gotham Narrow Book", 14, 0xFFFFFF);			messageTextField.defaultTextFormat = textFormat;						titleTextField.htmlText = newsTitle;			dateTextField.htmlText = date;			messageTextField.htmlText = message;						titleTextField.y = 0;			dateTextField.y = titleTextField.y + 25;			messageTextField.y = dateTextField.y + 30;			newsStory.addChild(titleTextField);			newsStory.addChild(dateTextField);			newsStory.addChild(messageTextField);						addChild(newsStory);			newsStory.x = 40;			newsStory.y = 80;			drawHorizontalRule(dateTextField.x + 40, dateTextField.y + dateTextField.height + 85);					}		private function drawHorizontalRule(xPos, yPos)		{			var line = new Sprite();			var lineLength = 60;			line.graphics.lineStyle(1,0xffffff,0.3);			line.graphics.moveTo(xPos, yPos);			line.graphics.lineTo(xPos + lineLength, yPos);			addChild(line);		}		// Public Methods:		// Protected Methods:	}	}