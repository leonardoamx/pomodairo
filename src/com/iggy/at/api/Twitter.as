package com.iggy.at.api
{
//import com.dynamicflash.util.Base64;

import flash.events.*;
import flash.net.*;
import flash.utils.Dictionary;
import flash.xml.*;

import com.iggy.at.api.data.*;
import com.iggy.at.api.events.TwitterEvent;
import com.iggy.at.api.utils.Base64;

/**
 * This is a wrapper class for the Twitter public API. This API uses 
 * 
 * The pattern for all of the calls is to:
 * 1.) Use XML for the format
 * 2.) Internally handle the event from the REST call
 * 3.) Parse the XML into a strongly typed object
 * 4.) Publish a TwitterEvent whose payload is the type object from above
 */ 
public class Twitter extends EventDispatcher
{
        // for search
        public static const ATOM_NS:Namespace = 
                new Namespace("http://www.w3.org/2005/Atom");

        // constants used for loaders
        private static const FRIENDS:String = "friends";
        private static const FRIENDS_TIMELINE:String = "friendsTimeline";
        private static const PUBLIC_TIMELINE:String = "timeline";
        private static const USER_TIMELINE:String = "userTimeline";
        private static const SET_STATUS:String = "setStatus";
        private static const FOLLOW_USER:String = "follow";
        private static const SHOW_STATUS:String = "showStatus";
        private static const REPLIES:String = "replies";
        private static const DESTROY:String = "destroy";
        private static const FOLLOWERS:String = "followers";
        private static const FEATURED:String = "featured";
        private static const GET_DIRECT_MESSAGES:String = "getDms";
        private static const SEND_DIRECT_MESSAGE:String = "sendDm";
        private static const SEARCH:String = "search";
        private static const VERIFY:String = "verify";
        private static const UPDATE_LOCATION:String = "updateLocation";
        private static const RATE_LIMIT_STATUS:String = "rateLimitStatus";
        private static const END_SESSION:String = "endSession";
        private static const GET_SENT_DIRECT_MESSAGES:String = "getSentDms";
        private static const SHOW_INFO:String = "showInfo";
        private static const FRIENDS_IDS:String = "friends/ids";
        private static const FOLLOWERS_IDS:String = "followers/ids";
        
        private static const LOAD_FRIENDS_URL:String = 
                "http://twitter.com/statuses/friends/$userId.xml";
        private static const LOAD_FRIENDS_TIMELINE_URL:String = 
                "http://twitter.com/statuses/friends_timeline/$userId.xml";
        private static const PUBLIC_TIMELINE_URL:String = 
                "http://twitter.com/statuses/public_timeline.xml"
        private static const LOAD_USER_TIMELINE_URL:String = 
                "http://twitter.com/statuses/user_timeline/$userId.xml"
        private static const FOLLOW_USER_URL:String = 
                "http://twitter.com/friendships/create/$userId.xml";
        private static const SET_STATUS_URL:String = 
                "http://twitter.com/statuses/update.xml";
        private static const SHOW_STATUS_URL:String = 
                "http://twitter.com/statuses/show/$id.xml";
        private static const REPLIES_URL:String = 
                "http://twitter.com/statuses/replies.xml";
        private static const DESTROY_URL:String = 
                "http://twitter.com/statuses/destroy/$id.xml";
        private static const FOLLOWERS_URL:String = 
                "http://twitter.com/statuses/followers.xml";
        private static const FEATURED_USERS_URL:String = 
                "http://twitter.com/statuses/featured.xml";
        private static const GET_DIRECT_MSGS_URL:String = 
                "http://twitter.com/direct_messages.xml?";
        private static const SEND_DIRECT_MSG_URL:String = 
                "http://twitter.com/direct_messages/new.xml";
        private static const SEARCH_URL:String = 
                "http://search.twitter.com/search.atom?";
        private static const VERIFY_URL:String = 
                "http://twitter.com/account/verify_credentials.xml";
        private static const UPDATE_LOCATON_URL:String = 
                "http://twitter.com/account/update_location";
        private static const RATE_LIMIT_STATUS_URL:String = 
                "http://twitter.com/account/rate_limit_status.xml";
        private static const END_SESSION_URL:String = 
                "http://twitter.com/account/end_session.xml";
        private static const GET_SENT_DIRECT_MESSAGE_URL:String = 
                "http://twitter.com/direct_messages/sent.xml";
        private static const SHOW_INFO_URL:String = 
                "http://twitter.com/users/show/${id}.xml";
        private static const FRIENDS_IDS_URL:String = 
                "http://twitter.com/friends/ids/${id}.xml";
        private static const FOLLOWERS_IDS_URL:String = 
                "http://twitter.com/followers/ids/${id}.xml";
        
        private static const LITE:String = "lite=true";
        private static const PAGE:String = "page=$page";
        
        // internal variables
        private var loaders:Array;
        // for auth
        private var authorizationHeader:URLRequestHeader;
        private var useHttps:Boolean = false;
        
        function Twitter() 
        {
                loaders = [];
                this.addLoader(FRIENDS, friendsHandler);
                this.addLoader(FRIENDS_TIMELINE, friendsTimelineHandler);
                this.addLoader(PUBLIC_TIMELINE, publicTimelineHandler);
                this.addLoader(USER_TIMELINE, userTimelineHandler);
                this.addLoader(SET_STATUS, setStatusHandler);
                this.addLoader(FOLLOW_USER, friendCreatedHandler);
                this.addLoader(SHOW_STATUS, showStatusHandler);
                this.addLoader(REPLIES, repliesHandler);
                this.addLoader(DESTROY, destroyHandler);
                this.addLoader(FOLLOWERS, followersHandler);
                this.addLoader(FEATURED, featuredHandler);
                this.addLoader(GET_DIRECT_MESSAGES, dmsHandler);
                this.addLoader(SEND_DIRECT_MESSAGE, sendDmHandler);
                this.addLoader(SEARCH, searchHandler);
                this.addLoader(VERIFY, verifyHandler);
                this.addLoader(UPDATE_LOCATION, updateLocationHandler);
                this.addLoader(RATE_LIMIT_STATUS, rateLimitStatusHandler);
                this.addLoader(END_SESSION, endSessionHandler);
                this.addLoader(GET_SENT_DIRECT_MESSAGES, getSentDmHandler);
                this.addLoader(SHOW_INFO, showInfoHandler);
                this.addLoader(FRIENDS_IDS, friendsIdsHandler);
                this.addLoader(FOLLOWERS_IDS, followersIdsHandler);
        }

        // The Public API
        /*
        *
         */
        
        /**
         * Sets the username and password for this instance, setting the
         * flag to use https to true. Note that this will not
         * work at all in Flash player 9.0.115, and will only work in later 
         * versions if the remote server has the 
         * <code>allow-http-request-headers-from</code> tag set permissively 
         * in its crossdomain policy file. For more information see: 
         * http://kb.adobe.com/selfservice/viewContent.do?externalId=kb403184. 
         * Unfortunately Twitter has it set to (as of Sept 2008): 
         * <allow-http-request-headers-from domain="*.twitter.com" headers="*" secure="true"/> 
         * which only lets in the twitter badges originating from twitter.com. Since 
         * that's the case, authentication will only work for AIR. 
         * 
         * If you use this for Flash in the browser, it will fail over 
         * to the browser's basic auth without an issue. 
         * 
         * @param username 
         * @param password
         */
         public function setAuthenticationCredentials(username:String, password:String):void 
         {
                if (username != null && password != null){
                        this.useHttps = true;
                        var creds:String = username + ":" + password;
                        var encodedCredentials:String = Base64.encode(creds);
                        authorizationHeader = 
                                new URLRequestHeader("Authorization", 
                                        "Basic " + encodedCredentials);
                }
         }
                        
        /**
        * Loads a list of Twitter friends and (optionally) their statuses. 
         * Authentication required for private users.
        */
        public function loadFriends(userId:String, lite:Boolean = true, page:int = 0):void
        {
                var friendsLoader:URLLoader = this.getLoader(FRIENDS);
                var urlStr:String = LOAD_FRIENDS_URL.replace("$userId", userId);
                if (lite || page){
                        urlStr += "?";
                }
                if (lite){
                        urlStr += LITE;
                }
                if (page){
                        if (lite){
                                urlStr += "&";
                        }
                        var pageStr:String = PAGE.replace("$page", page.toString());
                        urlStr += pageStr;
                }
                friendsLoader.load(twitterRequest(urlStr));
        }
        /**
        * Loads the timeline of all friends on Twitter. Authentication required for private users.
        */
        public function loadFriendsTimeline(userId:String):void
        {
                var friendsTimelineLoader:URLLoader = this.getLoader(FRIENDS_TIMELINE);
                friendsTimelineLoader.load(twitterRequest(LOAD_FRIENDS_TIMELINE_URL.replace("$userId",userId)));
        }
        /**
        * Loads the timeline of all public users on Twitter.
        */
        public function loadPublicTimeline():void
        {
                var publicTimelineLoader:URLLoader = this.getLoader(PUBLIC_TIMELINE);
                publicTimelineLoader.load(twitterRequest(PUBLIC_TIMELINE_URL));
        }
        /**
        * Loads the timeline of a specific user on Twitter. Authentication required for private users.
        */
        public function loadUserTimeline(userId:String):void
        {
                var userTimelineLoader:URLLoader = this.getLoader(USER_TIMELINE);
                userTimelineLoader.load(twitterRequest(LOAD_USER_TIMELINE_URL.replace("$userId", userId)));
        }
        
        /**
         * Follows a user. Right now this uses the /friendships/create/user.format
         */
        public function follow(userId:String):void
        {
                var req:URLRequest = twitterRequest(FOLLOW_USER_URL.replace("$userId",userId));
                req.method = "POST";
                this.getLoader(FOLLOW_USER).load(req);
        }
        /**
        * Sets user's Twitter status. Authentication required.
        */
        public function setStatus(statusString:String):void
        {
                if (statusString.length <= 140)
                {
                        var request : URLRequest = twitterRequest (SET_STATUS_URL);
                        request.method = "POST"
                        var variables : URLVariables = new URLVariables ();
                        variables.status = statusString;
                        request.data = variables;
                        try
                        {
                                this.getLoader(SET_STATUS).load (request);
                        } catch (error : Error)
                        {
                                trace ("Unable to set status");
                        }
                } else 
                {
                        trace ("STATUS NOT SET: status limited to 140 characters");
                }
        }
        
        /**
         * Returns a single status, specified by the id parameter below.  
         * The status's author will be returned inline.
         */
        public function showStatus(id:String):void
        {
                var showStatusLoader:URLLoader = this.getLoader(SHOW_STATUS);
                showStatusLoader.load(twitterRequest(SHOW_STATUS_URL.replace("$id",id)));
        }
        
        /**
         * Loads the most recent replies for the current authenticated user
         */
        public function loadReplies():void
        {
                var repliesLoader:URLLoader = this.getLoader(REPLIES);
                repliesLoader.load(twitterRequest(REPLIES_URL));
        }
        
        public function loadFollowers(lite:Boolean=true):void
        {
                var followersLoader:URLLoader = this.getLoader(FOLLOWERS);
                var urlStr:String = FOLLOWERS_URL;
                if (lite){
                        urlStr += "?"+LITE;
                }
                followersLoader.load(twitterRequest(urlStr));
        }
        
        public function loadFeatured():void
        {
                var featuredLoader:URLLoader = this.getLoader(FEATURED);
                featuredLoader.load(twitterRequest(FEATURED_USERS_URL));
        }
        
        public function loadDirectMessages():void
        {
                var dmLoader:URLLoader = this.getLoader(GET_DIRECT_MESSAGES);
                dmLoader.load(twitterRequest(GET_DIRECT_MSGS_URL));
        }
        
        public function sendDirectMessage(recipientScreenName:String, message:String):void
        {
                if (message.length <= 140)
                {
                        var request : URLRequest = twitterRequest (SEND_DIRECT_MSG_URL);
                        request.method = "POST"
                        var variables : URLVariables = new URLVariables ();
                        variables["user"] = recipientScreenName;
                        variables["text"] = message;
                        request.data = variables;
                        try
                        {
                                this.getLoader(SEND_DIRECT_MESSAGE).load (request);
                        } catch (error : Error)
                        {
                                trace ("Unable to send direct message");
                        }
                } else 
                {
                        trace ("DM NOT SENT: direct message limited to 140 characters");
                }               
        }
        
        public function search(query:TwitterSearch):void
        {
                var searchLoader:URLLoader = this.getLoader(SEARCH);
                var url:String = SEARCH_URL + query.queryString;
                /*
                var r:URLRequest = new URLRequest (url);
                if (this.authorizationHeader){
                        r.requestHeaders = [this.authorizationHeader];  
                }
                */
                searchLoader.load(twitterRequest(url));
        }
        
        public function verify():void {
                var verifyLoader:URLLoader = this.getLoader(VERIFY);
                verifyLoader.load(twitterRequest(VERIFY_URL));
        }
        
        public function updateLocation(location:String):void {
                var newLocation:String = location.replace(/ /g, "%20");
                var updateLocationLoader:URLLoader = this.getLoader(UPDATE_LOCATION);
                var request:URLRequest = twitterRequest(UPDATE_LOCATON_URL);
                request.method = URLRequestMethod.POST;
                var variable:URLVariables = new URLVariables();
                variable["location"] = location;
                request.data = variable;
                updateLocationLoader.load(request);
        }
        
        public function loadRateLimitStatus():void {
                var rateLimitStatusLoader:URLLoader = this.getLoader(RATE_LIMIT_STATUS);
                rateLimitStatusLoader.load(twitterRequest(RATE_LIMIT_STATUS_URL));
        }
        
        public function endSession():void {
                var endSessionLoader:URLLoader = this.getLoader(END_SESSION);
                var r:URLRequest = twitterRequest(END_SESSION_URL);
                r.method = URLRequestMethod.POST;
                endSessionLoader.load(r);
        }
        
        public function loadSentDirectMessage():void {
                var sentDirectMessageLoader:URLLoader = this.getLoader(GET_SENT_DIRECT_MESSAGES);
                sentDirectMessageLoader.load(twitterRequest(GET_SENT_DIRECT_MESSAGE_URL));
        }
        
        public function loadInfo(user:String):void {
                var info:URLLoader = this.getLoader(SHOW_INFO);
                info.load(twitterRequest(SHOW_INFO_URL.replace("${id}", user)));
        }
        
        public function loadFriendsIds(user:String):void{
                var friendsIdsLoader:URLLoader = this.getLoader(FRIENDS_IDS);
                friendsIdsLoader.load(twitterRequest(FRIENDS_IDS_URL.replace("${id}", user)));
        }
        
        public function loadFollowersIds(user:String):void{
                var followersIdsLoader:URLLoader = this.getLoader(FOLLOWERS_IDS);
                followersIdsLoader.load(twitterRequest(FOLLOWERS_IDS_URL.replace("${id}", user)));
        }
        
        
        /*
        *  private handlers for the events coming back from twitter
        *  the 
        * 
        */
        
        private function friendsHandler(e:Event):void 
        {
        	var xml:XML = new XML(this.getLoader(FRIENDS).data);
            var userArray:Array = new Array();
   			 for each (var tempXML:XML in xml.children()) 
   			 {
   			 	var twitterUser:TwitterUser = new TwitterUser(tempXML);
   			 	userArray.push(twitterUser);
   			 }
            var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FRIENDS_RESULT);
            r.data = userArray;
            dispatchEvent (r);
        }
                
        private function friendsTimelineHandler(e:Event):void 
        {
        var xml:XML = new XML(this.getLoader(FRIENDS_TIMELINE).data);
        var statusArray:Array = new Array();
    	for each (var tempXML:XML in xml.children())
    	 {
			var twitterStatus:TwitterStatus = new TwitterStatus (tempXML);
        	statusArray.push(twitterStatus );
    	 }
            var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FRIENDS_TIMELINE_RESULT);
            r.data = statusArray;
            dispatchEvent (r);
        }
        
        private function publicTimelineHandler(e:Event) :void
        {
        var xml:XML = new XML(this.getLoader(PUBLIC_TIMELINE).data);
        var statusArray:Array = new Array();
	    for each (var tempXML:XML in xml.children()) 
	    {
		    var twitterStatus:TwitterStatus = new TwitterStatus (tempXML);
		    statusArray.push(twitterStatus );
	    }
                var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_PUBLIC_TIMELINE_RESULT);
                r.data = statusArray;
                dispatchEvent (r);
        }
        
        private function userTimelineHandler(e:Event):void 
        {
        	var xml:XML = new XML(this.getLoader(USER_TIMELINE).data);
            var statusArray:Array = new Array();
	        for each (var tempXML:XML in xml.children()) 
	        {
	        	var twitterStatus:TwitterStatus = new TwitterStatus (tempXML)
	            statusArray.push(twitterStatus );
	        }
	        var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_USER_TIMELINE_RESULT);
	        r.data = statusArray;
	        dispatchEvent (r);
        }
        
        
        private function setStatusHandler (e : Event) : void{
                var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_SET_STATUS);
                r.data = "success";
                dispatchEvent (r);
        }
        
        private function friendCreatedHandler (e:Event) : void{
                trace("Friend created " + this.getLoader(FOLLOW_USER).data);
        }
        
        private function showStatusHandler(e:Event):void
        {
                var xml:XML = new XML(this.getLoader(SHOW_STATUS).data);
                var twitterStatus:TwitterStatus = new TwitterStatus(xml);
                var twitterEvent:TwitterEvent = new TwitterEvent(TwitterEvent.ON_SHOW_STATUS);
                twitterEvent.data = twitterStatus;
                dispatchEvent(twitterEvent);
        }
        
        private function repliesHandler(e:Event):void
        {
                var xml:XML = new XML(this.getLoader(REPLIES).data);
                var statusArray:Array = [];
                for each(var reply:XML in xml.children())
                {
                        statusArray.push(new TwitterStatus(reply));
                }
                var twitterEvent:TwitterEvent = new TwitterEvent(TwitterEvent.ON_REPLIES);
                twitterEvent.data = statusArray;
                dispatchEvent(twitterEvent);
        }
        
        private function destroyHandler(e:Event):void
        {
                var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_DESOTRY);
                r.data = "success";
                dispatchEvent (r);
        }
        
        private function errorHandler (errorEvent : IOErrorEvent) : void
        {
                trace (errorEvent.text);
                var t:TwitterEvent = new TwitterEvent(TwitterEvent.ON_ERROR);
                t.data = errorEvent.text;
                this.dispatchEvent(t);
        }
        
        private function followersHandler(e:Event):void
        { 
        	 var xml:XML = new XML(this.getLoader(FOLLOWERS).data);
        	 var userArray:Array = new Array();
        	 for each (var tempXML:XML in xml.children()) 
        	 {
             	var twitterUser:TwitterUser = new TwitterUser(tempXML);
             	userArray.push(twitterUser);
             }
             var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FOLLOWERS);
             r.data = userArray;
             dispatchEvent (r);
        }
        
        private function featuredHandler(e:Event):void
        {
                var xml:XML = new XML(this.getLoader(FEATURED).data);
                var userArray:Array = new Array();
    for each (var tempXML:XML in xml.children()) {
                        var twitterUser:TwitterUser = new TwitterUser(tempXML);
        userArray.push(twitterUser);
    }
                var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_FEATURED);
                r.data = userArray;
                dispatchEvent (r);
        }
        
        private function dmsHandler(e:Event):void
        {
                var xml:XML = new XML(this.getLoader(GET_DIRECT_MESSAGES).data);
                var dmArray:Array = new Array();
                for each (var tempXml:XML in xml.children())
                {
                        var dm:TwitterDirectMessage = new TwitterDirectMessage(tempXml);
                        dmArray.push(dm);
                }
                var t:TwitterEvent = new TwitterEvent(TwitterEvent.ON_GET_DIRECT_MESSAGES);
                t.data = dmArray;
                this.dispatchEvent(t);
        }
        
        private function sendDmHandler(e:Event):void
        {
                var r:TwitterEvent = new TwitterEvent (TwitterEvent.ON_DIRECT_MESSAGE_SENT);
                r.data = "success";
                dispatchEvent (r);                      
        }
        
        private function searchHandler(e:Event):void
        {
                var atom:Namespace = ATOM_NS;
                var xml:XML = new XML(this.getLoader(SEARCH).data);
                var results:Array = [];
                var entryXml:XML;
                for each (entryXml in xml.atom::entry)
                {
                        var entry:Object = {};
                        var idStr:String = entryXml.atom::id;
                        var idx:int = idStr.lastIndexOf(':');
                        entry.id = Number(idStr.substring(idx+1, idStr.length-1));
                        entry.text = entryXml.atom::title;
                        entry.created_at = entryXml.atom::updated;
                        entry.user = entryXml.atom::author.atom::name;
                        var status:TwitterStatus = new TwitterStatus(entry);
                        results.push(status);
                }
                var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_SEARCH);
                r.data = results;
                dispatchEvent(r);
        }
        
        private function verifyHandler(e:Event):void {
                var status:XML = new XML(this.getLoader(VERIFY).data);
                var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_VERIFY);
                var user:TwitterUser = new TwitterUser(status);
                r.data = user;
                dispatchEvent(r);
        }
        
        private function updateLocationHandler(e:Event):void {
                var xml:XML = new XML(this.getLoader(UPDATE_LOCATION).data);
                var children:XML = xml.child("location")[0];
                
                var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_UPDATE_LOCATION);
                r.data = children.toString();
                dispatchEvent(r);
        }
        
        private function rateLimitStatusHandler(e:Event):void {
                var xml:XML = new XML(this.getLoader(RATE_LIMIT_STATUS).data);
                var status:Dictionary = new Dictionary();
                status["remaining-hits"] = xml.child("remaining-hits")[0];
                status["hourly-limit"] = xml.child("hourly-limit")[0];
                status["reset-time-in-seconds"] = xml.child("reset-time-in-seconds")[0];
                status["reset-time"] = xml.child("reset-time")[0];
                var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_RATE_LIMIT_STATUS);
                r.data = status;
                dispatchEvent(r);
        }
        
        private function endSessionHandler(event:Event):void {
                var xml:XML = new XML(this.getLoader(END_SESSION).data);
                authorizationHeader = null;
                useHttps = false;
                var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_END_SESSION);
                r.data = "success";
                dispatchEvent(r);
        }
        
        private function getSentDmHandler(event:Event):void {
                var xml:XML = new XML(this.getLoader(GET_SENT_DIRECT_MESSAGES).data);
                var dmArray:Array = new Array();
                for each (var tempXml:XML in xml.children())
                {
                        var dm:TwitterDirectMessage = new TwitterDirectMessage(tempXml);
                        dmArray.push(dm);
                }
                var t:TwitterEvent = new TwitterEvent(TwitterEvent.ON_GET_SENT_DIRECT_MESSAGE);
                t.data = dmArray;
                this.dispatchEvent(t);
        }
        
        private function showInfoHandler(event:Event):void {
                var xml:XML = new XML(this.getLoader(SHOW_INFO).data);
                var user:TwitterUser = new TwitterUser(xml);
                var r:TwitterEvent = new TwitterEvent(TwitterEvent.ON_SHOW_INFO);
                r.data = user;
                this.dispatchEvent(r);
        }
        
        private function friendsIdsHandler(event:Event):void{
                var xml:XML = new XML(this.getLoader(FRIENDS_IDS).data);
                var ids:Array = [];
                var length:int = xml.id.length();
                for (var i:int=0;i<length;i++){
                        ids[i] = xml.id[i];
                }
                var t:TwitterEvent = new TwitterEvent(TwitterEvent.ON_FRIENDS_IDS);
                t.data = ids;
                this.dispatchEvent(t);
        }
        
        private function followersIdsHandler(event:Event):void{
                var xml:XML = new XML(this.getLoader(FOLLOWERS_IDS).data);
                var ids:Array = [];
                var length:int = xml.id.length();
                for (var i:int=0;i<length;i++){
                        ids[i] = xml.id[i];
                }
                var t:TwitterEvent = new TwitterEvent(TwitterEvent.ON_FOLLOWERS_IDS);
                t.data = ids;
                this.dispatchEvent(t);
        }
        
        // private helper methods
        
        private function addLoader(name:String, completeHandler:Function):void
        {
                var loader:URLLoader = new URLLoader();
                loader.addEventListener(Event.COMPLETE, completeHandler);
                loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
                loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
                this.loaders[name] = loader;
        }
        
        private function getLoader(name:String):URLLoader
        {
                return this.loaders[name] as URLLoader;
        }
        
        private function twitterRequest (url : String):URLRequest
        {
                var result:URLRequest = new URLRequest (url);
                if (this.authorizationHeader){
                	result.authenticate = false;  
                     result.requestHeaders = [this.authorizationHeader];  
                }
                return result;
        }//end function twitterRequest
	}
}