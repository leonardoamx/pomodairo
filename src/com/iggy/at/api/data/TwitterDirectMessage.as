package com.iggy.at.api.data
{
        public class TwitterDirectMessage extends TwitterStatus
        {
                public var recipient:TwitterUser;
                public function TwitterDirectMessage(status:Object)
                {
                        super(status, new TwitterUser(status.sender));
                        recipient = new TwitterUser(status.recipient);
                }
               
                public function get sender():TwitterUser
                {
                        return this.user;
                }
               
        }
}
