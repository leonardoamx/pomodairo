package com.pomodairo
{
	public class RegexUtils
	{
		public function RegexUtils()
		{
		}
		
		public function extractHashNumber(text:String):int {
			var pattern:RegExp = /#(?P<digits>\d+)/;
        	var hashTags:Array = pattern.exec(text);
        	if(hashTags != null && hashTags.length > 0) {        		
				return hashTags.digits;
        	}
        	return -1;
		}

		public function extractHashTags(text:String):Array {
			var pattern:RegExp = /#\w*+/g;
        	var hashTags:Array = text.match(pattern);
        	var result:Array = [];
        	for(var i:int = 0; i < hashTags.length; i++) {
        		result.push(String(hashTags[i]));
        	}
			return result;
		}
		
		public function extractTags(text:String):Array {
			var pattern:RegExp = /#\w*+/g;
        	var hashTags:Array = text.match(pattern);
        	var result:Array = [];
        	for(var i:int = 0; i < hashTags.length; i++) {
        		result.push(String(hashTags[i]).substr(1));
        	}
			return result;
		}

	}
}