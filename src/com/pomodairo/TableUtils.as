package com.pomodairo
{
	import mx.formatters.DateFormatter;
	
	public class TableUtils
	{
		private var formatter:DateFormatter;
		
		public function TableUtils()
		{
			formatter = new DateFormatter();
			formatter.formatString = "YYYY/MM/DD HH:NN";
		}

        public function getTableAsHtml(title:String, data:Array):String
        {
       	   var tmpArray:Array = data;
       	   if(tmpArray == null) {
       	     return "";
       	   }
       	
           var tmpString:String = "<html><head><title>"+title+"</title></head><body><table>";
           
           var keys:Array = [];
           tmpString += "<tr>";
           var i:int = 0;
           var removeRowIndex:int = 0;
           for (var key:String in tmpArray[0]){
           	 if(key == "mx_internal_uid") {
           	 	removeRowIndex = i;
           	 } else {
	            tmpString += "<td><b>"+key+"</b></td>";
           	 }
           	 keys.push(key);
             i++;
		   }  
           tmpString += "</tr>";
           
           for(var i:int = 0; i < tmpArray.length; i++)
           {
               tmpString += "<tr>";
               for(var j:int = 0; j < keys.length; j++) {
               	 if(j == removeRowIndex) {
               	 	continue;
               	 }
               	 if(tmpArray[i] != null) {
                   tmpString += "<td>" + tmpArray[i][keys[j]] + "</td>";
                 }
                 else {
                   tmpString += "<td></td>";	
                 }
               }
               tmpString += "</tr>";
           }
           tmpString += "</table></body></html>"
           
           return tmpString;
        }
        
        public function getTableAsCsv(data:Array):String
        {
       	   var tmpArray:Array = data;
       	   if(tmpArray == null) {
       	     return "";
       	   }
       	
           var tmpString:String = "";
           
           var keys:Array = [];
           var i:int = 0;
           var removeRowIndex:int = 0;
           for (var key:String in tmpArray[0]){
           	 if(key == "mx_internal_uid") {
           	 	removeRowIndex = i;
           	 } else {
	            tmpString += key+"\t";
           	 }
           	 keys.push(key);
             i++;
		   }  
           tmpString += "\n";
           
           for(var i:int = 0; i < tmpArray.length; i++)
           {
               for(var j:int = 0; j < keys.length; j++) {
               	 if(j == removeRowIndex) {
               	 	continue;
               	 }
               	 if(tmpArray[i] != null) {
                   tmpString += tmpArray[i][keys[j]];
                 }
                 tmpString += "\t";
               }
               tmpString += "\n";
           }
           
           return tmpString;
        }
        
        public function getPomodorosTableAsHtml(title:String, data:Array):String
        {
       	   var tmpArray:Array = data;
       	   if(tmpArray == null) {
       	     return "";
       	   }
       	
           var tmpString:String = "<html><head><title>"+title+"</title></head><body><table>";
           
           var keys:Array = [];
           tmpString += "<tr>";
           tmpString += "<td><b>ID</b></td>";
           tmpString += "<td><b>name</b></td>";
           tmpString += "<td><b>created</b></td>";
           tmpString += "<td><b>closed</b></td>";
           tmpString += "<td><b>estimated</b></td>";
           tmpString += "<td><b>pomodoros</b></td>";
           tmpString += "<td><b>delta</b></td>";
           tmpString += "<td><b>interruptions</b></td>";
           tmpString += "<td><b>unplanned</b></td>";
           tmpString += "<td><b>type</b></td>";
           tmpString += "<td><b>done</b></td>";
           tmpString += "</tr>";
           
           for(var i:int = 0; i < tmpArray.length; i++)
           {
           		var curPomodoro:Pomodoro = tmpArray[i];
                tmpString += "<tr>";
                tmpString += "<td>" + curPomodoro.id + "</td>";
                tmpString += "<td>" + curPomodoro.name + "</td>";
                tmpString += "<td>" + formatter.format(curPomodoro.created) + "</td>";
                tmpString += "<td>" + formatter.format(curPomodoro.closed) + "</td>";
                tmpString += "<td>" + curPomodoro.estimated + "</td>";
                tmpString += "<td>" + curPomodoro.pomodoros + "</td>";
                tmpString += "<td>" + (curPomodoro.pomodoros - curPomodoro.estimated) + "</td>";
                tmpString += "<td>" + curPomodoro.interruptions + "</td>";
                tmpString += "<td>" + curPomodoro.unplanned + "</td>";
                tmpString += "<td>" + curPomodoro.type + "</td>";
                tmpString += "<td>" + curPomodoro.done + "</td>";
                tmpString += "</tr>";
           }
           tmpString += "</table></body></html>"
           
           return tmpString;
        }
        
        public function getPomodorosTableAsCsv(data:Array):String
        {
       	   var tmpArray:Array = data;
       	   if(tmpArray == null) {
       	     return "";
       	   }
       	
           var tmpString:String = "";
           
           var keys:Array = [];
           tmpString += "ID\t";
           tmpString += "name\t";
           tmpString += "created\t";
           tmpString += "closed\t";
           tmpString += "estimated\t";
           tmpString += "pomodoros\t";
           tmpString += "delta\t";
           tmpString += "interruptions\t";
           tmpString += "unplanned\t";
           tmpString += "type\t";
           tmpString += "done\t";
           tmpString += "\n";
           
           for(var i:int = 0; i < tmpArray.length; i++)
           {
           		var curPomodoro:Pomodoro = tmpArray[i];
                tmpString += curPomodoro.id + "\t";
                tmpString += curPomodoro.name + "\t";
                tmpString += formatter.format(curPomodoro.created) + "\t";
                tmpString += formatter.format(curPomodoro.closed) + "\t";
                tmpString += curPomodoro.estimated + "\t";
                tmpString += curPomodoro.pomodoros + "\t";
                tmpString += (curPomodoro.pomodoros - curPomodoro.estimated) + "\t";
                tmpString += curPomodoro.interruptions + "\t";
                tmpString += curPomodoro.unplanned + "\t";
                tmpString += curPomodoro.type + "\t";
                tmpString += curPomodoro.done + "\t";
                tmpString += "\n";
           }
           
           return tmpString;
        }
	}
}