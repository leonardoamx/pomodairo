package com.iggy.at.api.data{
       
       /**
                * Object that contains information about a Twitter user
                */
        public class TwitterUser {
                /**
                * ID of the Twitter user
                */
                public var id:Number;
                /**
                * String containing the name of the Twitter status 
                */
                public var name:String;
                /**
                * String containing the name of the Twitter user
                */
                public var screenName:String;
                /**
                * String containing the geographic location of the Twitter user
                */
                public var location:String;
                /**
                * String containing a description of the Twitter user
                */
                public var description:String;
                /**
                * String containing the URL to the Twitter user's profile image
                */
                public var profileImageUrl:String;
                /**
                * String containing the URL to the Twitter user's home page, blog, etc.
                */
                public var url:String;
                
                public var isProtected:String;
                
                public var friendsCount:Number;
                
                public var followersCount:Number;
                
                public var createdAt:String;
                
                public var favouritesCount:String;
                
                public var utcOffset:String;
                
                public var timeZone:String;
                
                public var following:String;
                
                public var notifications:String;
                
                public var statusesCount:String;
                
                /**
                 * The user's latest status
                 */
                public var status:TwitterStatus;
                
                function TwitterUser(user:Object) {
                        if (user!=null) {
                                id = user.id;
                                name = user.name;
                                screenName = user.screen_name;
                                location = user.location;
                                description = user.description;
                                profileImageUrl = user.profile_image_url;
                                url = user.url;
                                followersCount = user.followers_count;
                                friendsCount = user.friends_count;
                                createdAt = user.created_at;
                                isProtected = user.protected;
                                favouritesCount = user.favourites_count;
                                utcOffset = user.utc_offset;
                                timeZone = user.time_zone;
                                following = user.following;
                                notifications = user.notifications;
                                statusesCount = user.statuses_count;
                                
                                if (user.status!=null && user.status.text!=null && user.status.text!="")
                                {
                                        try{
                                                this.status = new TwitterStatus(user.status,this);
                                        } catch (e:Error){
                                                this.status = null;
                                        }
                                }
                        }
                }
                
//              public function get id():Number { return ID; }
//              public function get url():String { return URL; }
                public function get screen_name():String { return screenName; }
                public function get profile_image_url():String { return profileImageUrl; }

        }
}

