package com.pomodairo.twitter
{
	import com.iggy.at.api.Twitter;
	import com.iggy.at.api.data.TwitterStatus;
	import com.iggy.at.api.events.TwitterEvent;
	import com.pomodairo.PomodoroEventDispatcher;
	import com.pomodairo.TaskManager;
	import com.pomodairo.components.TwitterConfigPanel;
	import com.pomodairo.events.ConfigurationUpdatedEvent;
	import com.pomodairo.events.PomodoroEvent;
	import com.pomodairo.events.TwitterPomodoroEvent;
	
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TwitterManager
	{
		public static const STATUS_LOGIN:String = "logged in";
		public static const STATUS_LOGOFF:String = "logged off";
		public static const STATUS_WORKING:String = "is working on";	
		public static const STATUS_FREE:String = "is free";
		public static const STATUS_BREAK:String = "is on a break";
		
		
		private var t:Twitter = new Twitter();
			
		private var username:String = "pomodoroTest"; 
		
		private var lastTweetId:Number = new Number(-1);
		
		private var currentTweetIndex:int = 0;
		
		private var reloadTimer:Timer = new Timer(5000);
		
		private var running:Boolean = false;
		
		private var postUpdate:Boolean = false;
		
		private var groupUsername:String = "Fred";
		
		public function TwitterManager()
		{
			PomodoroEventDispatcher.getInstance().addEventListener(ConfigurationUpdatedEvent.UPDATED, onConfigurationChange);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.START_POMODORO, onStartPomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.TIME_OUT, onDonePomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.START_BREAK, onStartBreak);
            reloadTimer.addEventListener(TimerEvent.TIMER, reloadTweets);
		}
		
		private function onConfigurationChange(e:ConfigurationUpdatedEvent):void {
			if (e.configElement.name == TwitterConfigPanel.ENABLED) 
			{
				var twitterEnabled:Boolean = e.configElement.value == "true";
				
				if (!running && twitterEnabled) {
					running = true;
					start();
				}
				
				if (running && !twitterEnabled) {
					running = false;
					stop();
				}
			}
			
			if (e.configElement.name == TwitterConfigPanel.POST_POMODOROS) 
			{
				postUpdate = e.configElement.value == "true";
			}
		}
		
		public function start():void
		{
			t = new Twitter();  
			t.setAuthenticationCredentials("pomodoroTest", "pomodoro");
			reloadTimer.start();
			reloadTweets();
		}
		
		public function stop():void
		{
			reloadTimer.stop();
		}
		
		private function reloadTweets(e:TimerEvent=null):void {
				trace("Reload Twitter messages...");
				t.loadUserTimeline(username);  
				t.addEventListener(TwitterEvent.ON_USER_TIMELINE_RESULT, populateTweets);
				/*				
				var query:TwitterSearch = new TwitterSearch();
				query.fromUser=username;
				t.addEventListener(TwitterEvent.ON_SEARCH, populateTweets);
				t.search(query);
				*/
			}
			
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
			
			
			/* ----------------------------------------------------
        			TWITTER POST UPDATE METHODS
	   	  	---------------------------------------------------- */
	   	  	
	   	  	private function postLogin():void {
				if (postUpdate) 
				{
					t.setStatus(groupUsername+" "+STATUS_LOGIN);
				}
				
			}
			
			private function postLogoff():void {
				if (postUpdate) 
				{
					t.setStatus(groupUsername+" "+STATUS_LOGOFF);
				}
				
			}
			
	   	  	private function postBusy():void {
				if (postUpdate) 
				{
					t.setStatus(groupUsername+" "+STATUS_WORKING+" '"+TaskManager.instance.activeTask.name+"'");
				}
				
			}
			
			private function postFree():void {
				if (postUpdate) 
				{
					t.setStatus(groupUsername+" "+STATUS_FREE);
				}
				
			}
			
			private function postOnBreak():void {
				if (postUpdate) 
				{
					t.setStatus(groupUsername+" "+STATUS_BREAK);
				}
				
			}
	   	  	
	   	  	
	   	  	/* ----------------------------------------------------
        			END OF TWITTER POST UPDATE METHODS
	   	  	---------------------------------------------------- */
	   	  	
	   	  	
			
			/* ----------------------------------------------------
        			EVENT LISTENER METHODS
	   	  	---------------------------------------------------- */
	   	  		
			private function onStartPomodoro(e:PomodoroEvent):void {
				trace("Twitter - Start Pomodoro");
				postBusy();
			}
			
			private function onDonePomodoro(e:PomodoroEvent):void {
				trace("Twitter - Done Pomodoro");
				postFree();
			}
			
			private function onStartBreak(e:PomodoroEvent):void {
				trace("Twitter - Start Break");
				postOnBreak();
			}
			
			
			/* ----------------------------------------------------
        			END OF EVENT LISTENER METHODS
	   	  	---------------------------------------------------- */
	}
}