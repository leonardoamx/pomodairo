package com.iggy.at.api.events
{
        import flash.events.Event;
        public class TwitterEvent extends Event
        {
                public static const ON_FRIENDS_RESULT : String = "onFriendsResult";
                public static const ON_FRIENDS_TIMELINE_RESULT: String = "onFriendsTimelineResult";
                public static const ON_USER_TIMELINE_RESULT: String = "onUserTimelineResult";
                public static const ON_PUBLIC_TIMELINE_RESULT : String = "onPublicTimelineResult";
                public static const ON_SET_STATUS : String = "onSetStatus";
                public static const ON_SET_MOBILE_NOTIFICATIONS : String = "onSetMobileNotifications";
                public static const ON_SHOW_STATUS:String = "onShowStatus";
                public static const ON_REPLIES:String = "onReplies";
                public static const ON_DESOTRY:String = "onDestroy";
                public static const ON_FOLLOWERS:String = "onFollowers";
                public static const ON_FEATURED:String = "onFeatured";
                public static const ON_GET_DIRECT_MESSAGES:String = "onGetDms";
                public static const ON_DIRECT_MESSAGE_SENT:String = "onDmSent";
                public static const ON_SEARCH:String = "onSearch";
                public static const ON_VERIFY:String = "onVerify";
                public static const ON_UPDATE_LOCATION:String = "onUpdateLocation";
                public static const ON_RATE_LIMIT_STATUS:String = "onRateLimitStatus";
                public static const ON_END_SESSION:String = "onEndSession";
                public static const ON_GET_SENT_DIRECT_MESSAGE:String = "onGetSentDirectMessage";
                public static const ON_SHOW_INFO:String = "onShowInfo";
                public static const ON_FRIENDS_IDS:String = "onFriendsIds";
                public static const ON_FOLLOWERS_IDS:String = "onFollowersIds";
                public static const ON_ERROR:String = "onError";
                public static const SUCCESS:String = "success";
                public static const FAIL:String = "fail";
                public var data : Object = new Object ();
                public function TwitterEvent (type : String, bubbles : Boolean = false, cancelable : Boolean = false)
                {
                        super (type, bubbles, cancelable);
                }
                
        }
}
