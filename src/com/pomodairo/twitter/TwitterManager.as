package com.pomodairo.twitter
{
	import com.pomodairo.PomodoroEventDispatcher;
	import com.pomodairo.TaskManager;
	import com.pomodairo.components.config.TwitterConfigPanel;
	import com.pomodairo.events.ConfigurationUpdatedEvent;
	import com.pomodairo.events.PomodoroEvent;
	import com.swfjunkie.tweetr.Tweetr;
	import com.swfjunkie.tweetr.oauth.OAuth;
	import com.swfjunkie.tweetr.oauth.events.OAuthEvent;
	
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	import mx.formatters.DateFormatter;
	
	public class TwitterManager
	{
		public static const STATUS_LOGIN:String = "logged in";
		public static const STATUS_LOGOFF:String = "logged off";
		public static const STATUS_WORKING:String = "is working on";	
		public static const STATUS_FREE:String = "is free";
		public static const STATUS_BREAK:String = "is on a break";
		
		// public static const SHORT_DATE_MASK:String	= "YYMMDD H:NN:SS";
		public static const SHORT_DATE_MASK:String	= "H:NN:SS";

	    /**
	    * Tweetr API instance
	    */
		private var twitter:TwitterClient;
		
		private var oauth:OAuth;

		private var lastTweetId:Number = new Number(-1);
		
		private var currentTweetIndex:int = 0;
		
		private var reloadTimer:Timer = new Timer(5000);
		
		private var twitterRunning:Boolean = false;
		
		private var postUpdate:Boolean = false;
		
		private var groupUsername:String;
		
		private var twitterEnabled:Boolean = false;
		
		
		public function TwitterManager()
		{
			PomodoroEventDispatcher.getInstance().addEventListener(ConfigurationUpdatedEvent.UPDATED, onConfigurationChange);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.START_POMODORO, onStartPomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.TIME_OUT, onDonePomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.START_BREAK, onStartBreak);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.STOP_POMODORO, onStopPomodoro);
            reloadTimer.addEventListener(TimerEvent.TIMER, reloadTweets);
            
         	twitter = new TwitterClient();
		}
		
		private function onConfigurationChange(e:ConfigurationUpdatedEvent):void {
			if (e.configElement.name == TwitterConfigPanel.ENABLED) 
			{
				twitterEnabled = e.configElement.value == "true";
				
				if (twitterEnabled) {
					checkStart();
				} else {
					// Make sure we remove shared secrets
					twitter.clearSharedCredentials();
				}
				
				if (twitterRunning && !twitterEnabled) {
					stop();
				}
			}
			
			if (e.configElement.name == TwitterConfigPanel.POST_POMODOROS) 
			{
				postUpdate = e.configElement.value == "true";
			}
			
			if (e.configElement.name == TwitterConfigPanel.GROUP_USERNAME) 
			{
				groupUsername = e.configElement.value;
				checkStart();
			}
		}
		
		public function checkStart():void
		{
			if (!twitterRunning && twitterEnabled) 
			{
				trace("Twitter enabled");
				twitterRunning = true;
				twitter.authenticate();
				reloadTimer.start();
				reloadTweets();
			}
		}
		
		public function stop():void
		{
			trace("Stop Twitter update");
			twitterRunning = false;
			reloadTimer.stop();
			postLogoff();
		}
		
		private function reloadTweets(e:TimerEvent=null):void {
				//trace("Reload Twitter messages...");
				// t.loadUserTimeline(username);  
				// t.addEventListener(TwitterEvent.ON_USER_TIMELINE_RESULT, populateTweets);
				/*				
				var query:TwitterSearch = new TwitterSearch();
				query.fromUser=username;
				t.addEventListener(TwitterEvent.ON_SEARCH, populateTweets);
				t.search(query);
				*/
			}
			
			/*
			private function populateTweets(e:TwitterEvent):void {
				var twitterStatus:TwitterStatus;
				var now:Number = new Date().getTime();
				
				var foundId:Number = new Number(-1);
				for (var i:String in e.data) {  
					twitterStatus = e.data[i]; 
					
					// TODO: I cant get search function to work (sinceId) so I am filtering manually.
					// this is not very resource efficient though...
					if (twitterStatus.id > lastTweetId) {
    					var created:Number = twitterStatus.createdAt.getTime();
						
						if (now - created < 1000*60*60*2) {
							if (foundId < twitterStatus.id) {
								foundId = twitterStatus.id;
							}
							
							var event:TwitterPomodoroEvent = new TwitterPomodoroEvent(TwitterPomodoroEvent.NEW);
							event.twitterStatus = twitterStatus;
							PomodoroEventDispatcher.getInstance().dispatchEvent(event);
							trace("Dispatched tweet: "+twitterStatus.createdAt+" - "+twitterStatus.text);
							
						} else  {
							// More than 2 hours old
							trace("Discarding old tweet: "+twitterStatus.createdAt+" - "+twitterStatus.text);
						}
						
					}
					
				}
				
				if (foundId > 0) {
					lastTweetId = foundId;
				}
			}  
			*/
			
			public static function dateFormat(date:Date):String {
				var formatter:DateFormatter = new DateFormatter();
				formatter.formatString = SHORT_DATE_MASK;
				return formatter.format(date);
			}
			
			
			/* ----------------------------------------------------
        			TWITTER POST UPDATE METHODS
	   	  	---------------------------------------------------- */
	   	  	
	   	  	private function postLogin():void {
				if (twitterEnabled && postUpdate) 
				{
					trace("Twitter - Post Login");
					twitter.setStatus(getPrefix()+STATUS_LOGIN);
				}
				
			}
			
			private function postLogoff():void {
				if (twitterEnabled && postUpdate) 
				{
					trace("Twitter - Post Logoff");
					twitter.setStatus(getPrefix()+STATUS_LOGOFF);
				}
				
			}
			
	   	  	private function postBusy():void {
				if (twitterEnabled && postUpdate) 
				{
					trace("Twitter - Post Busy");
					twitter.setStatus(getPrefix()+STATUS_WORKING+" '"+TaskManager.instance.activeTask.shortDescription+"'");
				}
				
			}
			
			private function postFree():void {
				if (twitterEnabled && postUpdate) 
				{
					trace("Twitter - Post Free");
					twitter.setStatus(groupUsername+" "+STATUS_FREE);
				}
				
			}
			
			private function postOnBreak():void {
				if (twitterEnabled && postUpdate) 
				{
					trace("Twitter - Post Break");
					twitter.setStatus(getPrefix()+STATUS_BREAK);
				}
				
			}
	   	  	
	   	  	private function getPrefix():String {
	   	  		var now:Date = new Date();
	   	  		var prefix:String = dateFormat(now)+" - "; 
	   	  		prefix += groupUsername+" ";
	   	  		return prefix;	
	   	  	}
	   	  	
	   	  	/* ----------------------------------------------------
        			END OF TWITTER POST UPDATE METHODS
	   	  	---------------------------------------------------- */
	   	  	
	   	  	
			
			/* ----------------------------------------------------
        			EVENT LISTENER METHODS
	   	  	---------------------------------------------------- */
	   	  		
			private function onStartPomodoro(e:PomodoroEvent):void {
				postBusy();
			}
			
			private function onDonePomodoro(e:PomodoroEvent):void {
				// postFree();
			}
			
			private function onStopPomodoro(e:PomodoroEvent):void {
				postFree();
			}
			
			private function onStartBreak(e:PomodoroEvent):void {
				postOnBreak();
			}
			
			
			/* ----------------------------------------------------
        			END OF EVENT LISTENER METHODS
	   	  	---------------------------------------------------- */
	}
}