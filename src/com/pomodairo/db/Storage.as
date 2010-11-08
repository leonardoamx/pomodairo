package com.pomodairo.db
{
	import com.pomodairo.ConfigProperty;
	import com.pomodairo.Pomodoro;
	import com.pomodairo.PomodoroEventDispatcher;
	import com.pomodairo.RegexUtils;
	import com.pomodairo.components.config.AdvancedConfigPanel;
	import com.pomodairo.events.ConfigurationUpdatedEvent;
	import com.pomodairo.events.PomodoroEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.errors.SQLError;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	import flash.utils.Dictionary;
	
	import mx.collections.ArrayCollection;
	
	//import org.osflash.thunderbolt.Logger;
	
	public class Storage
	{
		public static var DATABASE_FILE:String = "pomodairo-1.1.db";
		
		public static var instance:Storage = new Storage();
		
		[Bindable]
		public var dataset:Array;
		
		[Bindable]
		public var datasetStatistics1:Array;
		[Bindable]
		public var datasetStatistics2:Array;
		[Bindable]
		public var datasetStatistics3:Array;
		[Bindable]
		public var datasetStatistics4:Array;
		[Bindable]
		public var datasetStatistics5:Array;
		[Bindable]
		public var datasetStatistics6:Array;
		
		[Bindable]
		public var config:Dictionary = new Dictionary();
		
		private var databaseFolderLocation:String;
			
		private var sqlConnectionFile:File;
		private var sqlConnection:SQLConnection;
		private var dbStatement:SQLStatement;
		private var dbCfgStatement:SQLStatement;
		
		public function Storage() {
			databaseFolderLocation = AdvancedConfigPanel.getDatabaseLocation();
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.START_POMODORO, startPomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.TIME_OUT, completeCurrentPomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.NEW_INTERRUPTION, addInterruption);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.NEW_UNPLANNED, addUnplanned);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.NEW_POMODORO, addNewPomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.DONE, closePomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.EDITED, editPomodoro);
		}
		
		private function startPomodoro(e:PomodoroEvent):void {
			// Nothing to do here yet.
		}
		
		private function completeCurrentPomodoro(e:PomodoroEvent):void {
			increasePomodoroCount(e.pomodoro);
		}
		
		private function addInterruption(e:PomodoroEvent):void {
			addPomodoro(e.other);
			increaseInterruptionCount(e.pomodoro);
		}
		
		private function addUnplanned(e:PomodoroEvent):void {
			addPomodoro(e.other);
			increaseUnplannedCount(e.pomodoro);
		}
		
		private function editPomodoro(e:PomodoroEvent):void {
			updatePomodoro(e.other, e.pomodoro);
		}		
		
		private function addNewPomodoro(e:PomodoroEvent):void {
			addPomodoro(e.other);
		}
		
		private function closePomodoro(e:PomodoroEvent):void {
			markDone(e.pomodoro);
		}
		
		public function initAndOpenDatabase():void {
			if (databaseFolderLocation == null) {       		
				sqlConnectionFile = File.userDirectory.resolvePath(DATABASE_FILE);
			} else {
				sqlConnectionFile = new File(databaseFolderLocation+File.separator+DATABASE_FILE);
			}
			
			sqlConnection = new SQLConnection();
			
			if(!sqlConnectionFile.exists) {
				trace("Creating pomodairo database: "+sqlConnectionFile.url);
            	sqlConnection.open(sqlConnectionFile, SQLMode.CREATE);
            	createTable();
            	getAllPomodoros();
            } else {
            	trace("Pomodairo database found: "+sqlConnectionFile.url);
            	sqlConnection.addEventListener(SQLEvent.OPEN, onSQLConnectionOpened);
            	sqlConnection.open(sqlConnectionFile, SQLMode.UPDATE);
            }
            checkConfigurationTable();
            getAllConfig();
		}
		
		public function initViews():void {
			getPomodorosOfDay(new Date());
			getInterruptionsOfDay(new Date());
			getPomodorosPerDay();
			getRealityFactors();
			getPomodoroHashTags();
			getInterruptionHashTags();
		}
		
		private function onSQLConnectionOpened(event:SQLEvent):void {
		if (event.type == "open") {
				migrateFrom15to16();
				getAllPomodoros();
			}
		}
		
		
		private function createTable():void {
			trace("Create new table");
		 	var q:SQLStatement = new SQLStatement();
		 	q.sqlConnection = sqlConnection;
		 	
		 	var sql:String = "CREATE TABLE IF NOT EXISTS pomodoro( " +
		 				"id INTEGER PRIMARY KEY ASC, " +
		 				"name TEXT, " +
		 				"type TEXT, " +
		 				"pomodoros INTEGER, " +
		 				"unplanned INTEGER, " +
		 				"interruptions INTEGER, " +
		 				"created DATETIME, " +
		 				"closed DATETIME, " +
		 				"parent INTEGER, " +
		 				"visible BOOLEAN, " +
		 				"ordinal INTEGER, " +
		 				"done BOOLEAN, " +
		 				"estimated INTEGER )";
		 					
		 	q.text = sql;
		 	q.addEventListener( SQLErrorEvent.ERROR, createError );
		 	q.execute();
		}

		public function getAllPomodoros():void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select * from Pomodoro where (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"') and visible=true " + 
					"order by ordinal desc, done desc, closed, strftime('%Y/%m/%d',created)!=strftime('%Y/%m/%d','now') desc, pomodoros desc, estimated desc";
			dbStatement.text = sqlQuery;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.execute();
		}
		
		public function getOpenPomodoros():ArrayCollection
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select * from Pomodoro where (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"') and visible=true " + 
					"and done=false order by ordinal desc";
			dbStatement.text = sqlQuery;
			dbStatement.execute();
			var result:SQLResult = dbStatement.getResult();
			return new ArrayCollection(result.data);
		}
		
		public function getAllItems():void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select * from Pomodoro";
			dbStatement.text = sqlQuery;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.execute();
		}
		
		private function getStartDate(date:Date, range:Number):Date {
			if(range < 0) {
				return new Date(date.fullYear, date.month, date.date + range);
			}
			else {
				return new Date(date.fullYear, date.month, date.date);
			}
		}
		private function getEndDate(date:Date, range:Number):Date {
			if(range <= 0) {
				return new Date(date.fullYear, date.month, date.date, 23, 59, 59);
			}
			else {
				return new Date(date.fullYear, date.month, date.date + range, 23, 59, 59);
			}
		}

		public function getPomodorosOfDay(day:Date, range:Number = -1, filter:String = ""):void
		{ 
			var filterSql:String = "";
			if(filter != "") {
				filterSql = " and name like '%"+filter+"%'";
			}
			dbStatement = new SQLStatement();
			//dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select name, substr(type,0,1) AS type,strftime('%Y/%m/%d %H:%S',closed) AS closed, estimated, pomodoros, (pomodoros - estimated) AS delta, (unplanned + interruptions) AS interruptions from Pomodoro where closed > strftime( '%J', :startDate ) and closed <= strftime( '%J', :endDate ) and (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"') and done=1"+filterSql;
			dbStatement.text = sqlQuery;
			dbStatement.parameters[":startDate"]= getStartDate(day, range);
			dbStatement.parameters[":endDate"]= getEndDate(day, range);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementStatisticsResult1);
			dbStatement.execute();
		}
		
		public function getInterruptionsOfDay(day:Date, range:Number = -1, filter:String = ""):void
		{
			var filterSql:String = "";
			if(filter != "") {
				filterSql = " and name like '%"+filter+"%'";
			}
			dbStatement = new SQLStatement();
			//dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select name, strftime('%Y/%m/%d %H:%S',created) AS created, type, parent from Pomodoro where created > strftime( '%J', :startDate ) and created <= strftime( '%J', :endDate ) and (type='"+Pomodoro.TYPE_INTERRUPTION+"' or type='"+Pomodoro.TYPE_UNPLANNED+"')"+filterSql;
			dbStatement.text = sqlQuery;
			dbStatement.parameters[":startDate"]= getStartDate(day, range);
			dbStatement.parameters[":endDate"]= getEndDate(day, range);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementStatisticsResult3);
			dbStatement.execute();
		}
		
		public function getPomodorosPerDay():void
		{
			// Created pomodoros per day, not the pomodoros done!
			dbStatement = new SQLStatement();
			//dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "SELECT strftime('%Y/%m/%d',created) AS created, sum(estimated) AS estimated, sum(pomodoros) AS pomodoros, (sum(interruptions) + sum(unplanned)) AS interruptions, (sum(pomodoros)-sum(estimated)) AS delta FROM pomodoro GROUP BY created";
			dbStatement.text = sqlQuery;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementStatisticsResult2);
			dbStatement.execute();
		}
		
		public function getRealityFactors():void
		{
			// Created pomodoros per week, not the pomodoros done!
			dbStatement = new SQLStatement();
			//dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "SELECT strftime('%W',created)+1 AS week, round(cast(sum(pomodoros) as real)/sum(estimated),2) AS factor, sum(estimated) AS estimated, sum(pomodoros) AS pomodoros, (sum(interruptions) + sum(unplanned)) AS interruptions, (sum(pomodoros)-sum(estimated)) AS delta FROM pomodoro GROUP BY week";
			dbStatement.text = sqlQuery;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementStatisticsResult4);
			dbStatement.execute();
		}
		
		public function getPomodoroHashTags():void
		{
			var regexUtils:RegexUtils = new RegexUtils();
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "SELECT * FROM pomodoro WHERE name like '%#%' and (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"')";
			dbStatement.text = sqlQuery;
			dbStatement.execute();
			var tempResult:SQLResult = dbStatement.getResult();
			var result:Array = [];
			if(tempResult.data != null) {
				for(var i:int = 0; i<tempResult.data.length; i++) {
					var tags:Array = regexUtils.extractHashTags(tempResult.data[i].name);
					for(var j:int=0; j < tags.length; j++) {					
						result.push(tags[j]);
					}
				}
				this.datasetStatistics5 = removeDuplicates(result);
			}
			else {
				this.datasetStatistics6 = result;
			}
		}
		public function getInterruptionHashTags():void
		{
			var regexUtils:RegexUtils = new RegexUtils();
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "SELECT * FROM pomodoro WHERE name like '%#%' and (type='"+Pomodoro.TYPE_INTERRUPTION+"' or type='"+Pomodoro.TYPE_UNPLANNED+"')";
			dbStatement.text = sqlQuery;
			dbStatement.execute();
			var tempResult:SQLResult = dbStatement.getResult();
			var result:Array = [];
			if(tempResult.data != null) {
				for(var i:int = 0; i<tempResult.data.length; i++) {
					var tags:Array = regexUtils.extractHashTags(tempResult.data[i].name);
					for(var j:int=0; j < tags.length; j++) {					
						result.push(tags[j]);
					}
				}
				this.datasetStatistics6 = removeDuplicates(result);
			}
			else {
				this.datasetStatistics6 = result;
			}
		}
		
		private function removeDuplicates(arr:Array):Array
		{
			var currentValue:String = "";
			var tempArray:Array = new Array();
			arr.sort(Array.CASEINSENSITIVE);
			arr.forEach(
				function(item:*, index:uint, array:Array):void {
					if (currentValue != item) {
						tempArray.push(item);
						currentValue= item;
					}
				}
			);
			return tempArray.sort(Array.CASEINSENSITIVE);
		}
		
		private function onDBStatementStatisticsResult1(event:SQLEvent):void
		{
			var result:SQLResult = dbStatement.getResult();
		    if (result != null)
		    {
		    	datasetStatistics1 = result.data;
		    }
		}
		private function onDBStatementStatisticsResult2(event:SQLEvent):void
		{
			var result:SQLResult = dbStatement.getResult();
		    if (result != null)
		    {
		    	datasetStatistics2 = result.data;
		    }
		}
		private function onDBStatementStatisticsResult3(event:SQLEvent):void
		{
			var result:SQLResult = dbStatement.getResult();
		    if (result != null)
		    {
		    	datasetStatistics3 = result.data;
		    }
		}
		private function onDBStatementStatisticsResult4(event:SQLEvent):void
		{
			var result:SQLResult = dbStatement.getResult();
		    if (result != null)
		    {
		    	datasetStatistics4 = result.data;
		    }
		}
		
		private function onDBStatementSelectResult(event:SQLEvent):void
		{
			var result:SQLResult = dbStatement.getResult();
		    if (result != null)
		    {
		    	dataset = result.data;
		    }
		}
		
		private function onDBStatementInsertResult(event:SQLEvent):void
		{
		    if (sqlConnection.totalChanges >= 1)
		    {
		    	getAllPomodoros();
		    }
		}

		private function createError(event:SQLErrorEvent):void {
		 	trace( 'Create Table Failed. Message: '+event );
		}
		
		private function createResult(event:SQLEvent):void {
		 	trace( 'Query Created Successfully' );
		}
		
		public function addPomodoro(pom:Pomodoro):void
        {
        	var sqlInsert:String = "insert into Pomodoro " + 
        			"(name, type, pomodoros, estimated, unplanned, interruptions, created, closed, done, parent, visible, ordinal) " + 
        			"values" + 
        			"(:name,:type,:pomodoros,:estimated,:unplanned,:interruptions,:created,:closed,:done, :parent, :visible, :ordinal);";
        			
			dbStatement.text = sqlInsert;
			dbStatement.parameters[":name"] = pom.name;
			dbStatement.parameters[":type"] = pom.type; 
			dbStatement.parameters[":pomodoros"] = pom.pomodoros; 
			dbStatement.parameters[":estimated"] = pom.estimated; 
			if(pom.estimated < 0) {
				dbStatement.parameters[":estimated"] = null; 
			}
			dbStatement.parameters[":unplanned"] = pom.unplanned; 
			dbStatement.parameters[":interruptions"] = pom.interruptions; 
			dbStatement.parameters[":created"] = pom.created; 
			dbStatement.parameters[":closed"] = pom.closed; 
			dbStatement.parameters[":done"] = pom.done;
			dbStatement.parameters[":parent"] = pom.parent;
			dbStatement.parameters[":visible"] = pom.visible;
			dbStatement.parameters[":ordinal"] = pom.ordinal;          
			
			dbStatement.removeEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
        }
        
        public function updatePomodoro(updated:Pomodoro, old:Pomodoro):void
        {
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlUpdate:String = "update Pomodoro set name= '" + updated.name + "', estimated=" + updated.estimated + " where id='" + old.id + "';";
			dbStatement.text = sqlUpdate;
			
			// Don't know why we are doing this?
			dbStatement.removeEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			
			dbStatement.execute();        	
        }
	
	
		public function remove(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlDelete:String = "delete from Pomodoro where id='"+pom.id+"';";
			dbStatement.text = sqlDelete;
			dbStatement.removeEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}
		
		public function markDone(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlMarkDone:String = "update Pomodoro set done = :done, closed = strftime( '%J', :closed ) where id=:id;";
			dbStatement.text = sqlMarkDone;
			dbStatement.parameters[":id"] = pom.id;
			dbStatement.parameters[":done"] = pom.done;
			dbStatement.parameters[":closed"] = pom.closed;
			//Logger.debug("Updating pomodoro to 'done'...", pom.closed);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function updateVisibility(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlMarkDone:String = "update Pomodoro set visible = "+pom.visible+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}	
		
		public function updateOrdinal(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlMarkDone:String = "update Pomodoro set ordinal = "+pom.ordinal+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increasePomodoroCount(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			trace("Increase DB Pomodoro count: "+pom.pomodoros);
			pom.pomodoros++;
			var sqlMarkDone:String = "update Pomodoro set pomodoros = "+pom.pomodoros+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increaseInterruptionCount(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			pom.interruptions++;
			var sqlMarkDone:String = "update Pomodoro set interruptions = "+pom.interruptions+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increaseUnplannedCount(pom:Pomodoro):void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			pom.unplanned++;
			var sqlMarkDone:String = "update Pomodoro set unplanned = "+pom.unplanned+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}
		
		
		
		/* ----------------------------------------------------
			        CONFIGURATION TABLE STUFF
		   ---------------------------------------------------- */
		   
		/**
		 * New since 1.4. This method will create a configuration table if none exists.
		 */
		private function checkConfigurationTable():void {
		 	var q:SQLStatement = new SQLStatement();
		 	q.sqlConnection = sqlConnection;
		 	
		 	var sql:String = "CREATE TABLE IF NOT EXISTS config( " +
		 				"name TEXT PRIMARY KEY, " +
		 				"value TEXT )";
		 					
		 	q.text = sql;
		 	q.addEventListener( SQLEvent.RESULT, createResult );
		 	q.addEventListener( SQLErrorEvent.ERROR, createError );
		 	q.execute();
		}
		
		public function getAllConfig():void
		{
			dbCfgStatement = new SQLStatement();
			dbCfgStatement.itemClass = ConfigProperty;
			dbCfgStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select * from Config";
			dbCfgStatement.text = sqlQuery;
			dbCfgStatement.addEventListener(SQLEvent.RESULT, getSelectConfigResult);
			dbCfgStatement.execute();
		}
		
		private function getSelectConfigResult(event:SQLEvent):void
		{
			var result:SQLResult = dbCfgStatement.getResult();
		    if (result != null)
		    {
		    	for each (var cfg:ConfigProperty in result.data) 
		    	{
		    		config[cfg.name] = cfg.value;	
		    	}
		    }
		}
		
		private function onConfigInsertResult(event:SQLEvent):void
		{
		    if (sqlConnection.totalChanges >= 1)
		    {
		    	getAllConfig();
		    }
		}
				
		public function setConfigurationValue(name:String, value:String):void
		{
			var cfg:ConfigProperty = new ConfigProperty();
			cfg.name = name;
			cfg.value = value;
			setConfiguration(cfg);
		}
		
		public function setConfiguration(prop:ConfigProperty):void
		{
			var sqlMarkDone:String = "REPLACE INTO Config (name,value) VALUES ('"+prop.name+"','"+prop.value+"')";
			dbCfgStatement.text = sqlMarkDone;
			dbCfgStatement.addEventListener(SQLEvent.RESULT, onConfigInsertResult);
			dbCfgStatement.execute();
		}
		
		public function removeConfiguration(key:String):void
		{
			var sqlRemoveConfig:String = "DELETE FROM Config WHERE name='"+key+"';";
			dbCfgStatement.text = sqlRemoveConfig;
			dbCfgStatement.execute();
		}
		   
		/* ----------------------------------------------------
			        END OF CONFIGURATION TABLE STUFF
		   ---------------------------------------------------- */
		   
   	    /* ----------------------------------------------------
		        	MIGRATION STUFF
	   	  ---------------------------------------------------- */
   
		public function migrateFrom15to16():void {
			var statement:SQLStatement = new SQLStatement();
			statement.itemClass = ConfigProperty;
			statement.sqlConnection = sqlConnection;
			var migrateSQL:String = "ALTER TABLE pomodoro ADD estimated INTEGER";
			statement.text = migrateSQL;
			try {
				statement.execute();
			} catch (err:SQLError) {
			  // Ignore migration errors
			  // Alert.show("Migration reported error: "+err);
			}

		}

		/* ----------------------------------------------------
		        	END OF MIGRATION STUFF
	   	  ---------------------------------------------------- */
	   	  
	   	  
	}
	
}