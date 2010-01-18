package com.iggy.at
{
	import com.iggy.at.api.Twitter;
	import com.iggy.at.api.data.TwitterStatus;
	import com.iggy.at.api.data.TwitterUser;
	import com.iggy.at.api.events.TwitterEvent;
	
	import mx.collections.ArrayCollection;
	
	public class TwitterConn
	{
		private var tw:Twitter;
		private var _userDetails:TwitterUserVO;
		private var _logedUserProfile:TwitterUser;
		private var _timelineDP:ArrayCollection;
		private var _followersDP:ArrayCollection;
		
		public function get userDetails():TwitterUserVO
		{
			return _userDetails;
		}
		public function get logedUserProfile():TwitterUser
		{
			return _logedUserProfile;
		}
		public function get followersDP():ArrayCollection
		{
			return _followersDP;
		}
		public function get timelineDP():ArrayCollection
		{
			return _timelineDP;
		}
		
		public function TwitterConn()
		{
			tw = new Twitter();
			tw.addEventListener( TwitterEvent.ON_USER_TIMELINE_RESULT, loadedUserTimeline );
			_timelineDP = new ArrayCollection();
		}
		
		public function TwitterConnAuth(user:String, pass:String):void
		{
			tw = new Twitter();
			tw.setAuthenticationCredentials(user, pass);
			
			tw.addEventListener( TwitterEvent.ON_FOLLOWERS_IDS, loadFriendsIds );
			_followersDP = new ArrayCollection();
		}
		
		 
		public function loadUserTimeline( nick:String ):void
		{
			if( nick == "" )
			return;
			tw.loadUserTimeline( nick );
		}
		
		// called when user timeline is returned from webservices
		private function loadedUserTimeline( evt:TwitterEvent ):void
		{
		// access timeline messages array
		var timeline:Array = evt.data as Array;
		// clear previous messages list contents
		_timelineDP.removeAll();
		// if no timeline found for specified user
		// exit function execution
		// user probably doesn't exists
			if(timeline == null || timeline.length == 0 )
				{
				return;
				}
		var twitStatus:TwitterStatus; //TwitterStatus used to loop
			for each( twitStatus in timeline )
				{
				_timelineDP.addItem( twitStatus );
				}
		_logedUserProfile = twitStatus.user;
		_userDetails = new TwitterUserVO();
		_userDetails.source = logedUserProfile.profileImageUrl;
		_userDetails.name = logedUserProfile.name;
		_userDetails.screenName = logedUserProfile.screenName;
		_userDetails.location = logedUserProfile.location;
		_userDetails.url = logedUserProfile.url;
		_userDetails.description = logedUserProfile.description;
		}
		
		public function loadFriendsIdsMo( nick:String):void
		{
			
			tw.loadFriendsIds(nick);
		}
		// called when user timeline is returned from webservices
		private  function loadFriendsIds( evt:TwitterEvent ):void
		{
		// access timeline messages array
		var timeline:Array = evt.data as Array;
		// clear previous messages list contents
		_followersDP.removeAll();
		// if no timeline found for specified user
		// exit function execution
		// user probably doesn't exists
			if(timeline == null || timeline.length == 0 )
				{
				return;
				}
			var twitUser:TwitterUser; //TwitterStatus used to loop
			for each( twitUser  in timeline )
				{
				_followersDP.addItem( twitUser );
				}
		
		}
	
	}//end of class
}