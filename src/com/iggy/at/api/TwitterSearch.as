package com.iggy.at.api
{
	public class TwitterSearch
	{
		private var keywords:Array;
        private var _fromUser:String;
        private var toUser:Array;
        private var refUser:Array;
        private var hashtags:Array;
        private var _lang:String;
        private var _numResults:int;
        private var _sinceId:String;
        private var _geocode:String;
        private var _showUser:Boolean = false;
        private var _near:String;
        private var _within:String;
                
        public function addKeyword(keyword:String, or:Boolean=false, not:Boolean=false):void
        {
                // this would not make any sense, so just ignore it
                if (or && not){
                        return;
                }
                keyword = encodeKeyword(keyword);
                if (or){
                        keyword = "OR+"+keyword;
                }
                if (not){
                        keyword = "-"+keyword;
                }
                keywords = safeAddToArray(keywords, keyword);
        }
        
        public function set fromUser(user:String):void
        {
                _fromUser = user;
        }
        
        public function addToUser(user:String):void
        {
                toUser = safeAddToArray(toUser, user);
        }
        
        public function addRefUser(user:String):void
        {
                refUser = safeAddToArray(refUser, user);
        }
        
        public function addHashtag(hashtag:String):void
        {
                hashtags = safeAddToArray(hashtags, hashtag);
        }
        
        public function set lang(language:String):void
        {
                _lang = language;
        }
        
        public function set numResults(rpp:int):void
        {
                _numResults = rpp;
        }
        
        public function set sinceId(tweetId:String):void
        {
                _sinceId = tweetId;
        }
        
        public function nearLocation(lat:Number, long:Number, radius:Number, units:String='mi'):void
        {
                _geocode = lat + '%2C' + long + '%2C' + radius + units;
        }
        
        public function nearPointOfInterest(name:String, radius:Number=0, units:String="mi"):void
        {
                name = encodeKeyword(name);
                _near = name;
                if (radius){
                        _within = radius.toString() + units;
                }
        }
        
        public function set showUser(showUserFlag:Boolean):void
        {
                _showUser = showUserFlag;
        }
        
        public function get queryString():String
        {
                var qs:String = 'q=';
                var params:Array = [];
                if (keywords)
                {
                        params.push(keywords.join('+'));
                }
                if (_fromUser)
                {
                        params.push('from%3A' + _fromUser);
                }
                if (toUser)
                {
                        params.push(toUser.map(addTo).join('+'));
                }
                if (refUser)
                {
                        params.push(refUser.map(addRef).join('+'));
                }
                if (hashtags && hashtags.length > 0)
                {
                        params.push(hashtags.map(addHash).join('+'));
                }
                qs += params.join('+');
                if (_lang)
                {
                        qs += '&lang=' + _lang;
                }
                if (_numResults)
                {
                        qs += '&rpp=' + String(_numResults);
                }
                if (_sinceId)
                {
                        qs += '&since_id=' + String(_sinceId);
                }
                if (_geocode)
                {
                        qs += '&geocode=' + _geocode;
                }
                if (_near)
                {
                        if (qs.length > 2){
                                qs += '+';
                        }
                        qs += 'near%3A' + _near;
                        if (_within)
                        {
                                qs += '+within%3A' + _within;
                        }
                }
                if (_showUser)
                {
                        qs += '&show_user=true';
                }
                return qs;
        }
        
        private static function safeAddToArray(array:Array, value:Object):Array
        {
                if (!array)
                {
                        array = [];
                }
                if (value)
                {
                        array.push(value);
                }
                return array;
        }
        
        private static function addTo(element:*, index:int, arr:Array):String
        {
                return addToken('to%3A',element);
        }
        
        private static function addRef(element:*, index:int, arr:Array):String
        {
                return addToken('%40', element);
        }
        private static function addHash(element:*, index:int, arr:Array):String
        {
                return addToken('%23', element);
        }
        private static function addToken(token:String, element:*):String
        {
                return token + String(element);
        }
        private static function encodeKeyword(kw:String):String
        {
                var ws:RegExp = /(\w)+/g;
                if (kw.indexOf(" ") > 0){
                        kw = kw.replace(" ", "+");
                        kw = "\"" + kw + "\"";
                }
                return kw;
        }

	}
}