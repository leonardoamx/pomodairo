package com.pomodairo.db
{
	import com.pomodairo.Pomodoro;
	import com.pomodairo.PomodoroEventDispatcher;
	import com.pomodairo.events.PomodoroEvent;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class Storage
	{
		public static var DATABASE_FILE:String = "pomodairo-1.1.db";
		
		public static var instance:Storage = new Storage();
		
		[Bindable]
		public var dataset:Array;
			
		private var sqlConnectionFile:File;
		private var sqlConnection:SQLConnection;
		private var dbStatement:SQLStatement;
		
		public function Storage() {
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.START_POMODORO, startPomodoro);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.NEW_INTERRUPTION, addInterruption);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.NEW_UNPLANNED, addUnplanned);
			PomodoroEventDispatcher.getInstance().addEventListener(PomodoroEvent.NEW_POMODORO, addNewPomodoro);
		}
		
		private function startPomodoro(e:PomodoroEvent) {
			increasePomodoroCount(e.pomodoro);
		}
		
		private function addInterruption(e:PomodoroEvent) {
			addPomodoro(e.other);
			increaseInterruptionCount(e.pomodoro);
		}
		
		private function addUnplanned(e:PomodoroEvent) {
			addPomodoro(e.other);
			increaseUnplannedCount(e.pomodoro);
		}
		
		private function addNewPomodoro(e:PomodoroEvent) {
			addPomodoro(e.other);
		}
		
		public function initAndOpenDatabase():void {       		
			sqlConnectionFile = File.userDirectory.resolvePath(DATABASE_FILE);
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
		}
		
		private function onSQLConnectionOpened(event:SQLEvent):void {
		if (event.type == "open") {
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
		 				"done BOOLEAN )";
		 					
		 	q.text = sql;
		 	q.addEventListener( SQLEvent.RESULT, createResult );
		 	q.addEventListener( SQLErrorEvent.ERROR, createError );
		 	q.execute();
		}

		public function getAllPomodoros():void
		{
			dbStatement = new SQLStatement();
			dbStatement.itemClass = Pomodoro;
			dbStatement.sqlConnection = sqlConnection;
			var sqlQuery:String = "select * from Pomodoro where (type='"+Pomodoro.TYPE_POMODORO+"' or type='"+Pomodoro.TYPE_UNPLANNED+"') and visible=true";
			dbStatement.text = sqlQuery;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.execute();
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
		 	trace( 'Create Table Failed' );
		}
		
		private function createResult(event:SQLEvent):void {
		 	trace( 'Query Created Successfully' );
		}
		
		public function addPomodoro(pom:Pomodoro):void
        {
        	var sqlInsert:String = "insert into Pomodoro " + 
        			"(name, type, pomodoros, unplanned, interruptions, created, closed, done, parent, visible) " + 
        			"values" + 
        			"(:name,:type,:pomodoros,:unplanned,:interruptions,:created,:closed,:done, :parent, :visible);";
        			
			dbStatement.text = sqlInsert;
			dbStatement.parameters[":name"] = pom.name;
			dbStatement.parameters[":type"] = pom.type; 
			dbStatement.parameters[":pomodoros"] = pom.pomodoros; 
			dbStatement.parameters[":unplanned"] = pom.unplanned; 
			dbStatement.parameters[":interruptions"] = pom.interruptions; 
			dbStatement.parameters[":created"] = pom.created; 
			dbStatement.parameters[":closed"] = pom.closed; 
			dbStatement.parameters[":done"] = pom.done;
			dbStatement.parameters[":parent"] = pom.parent;
			dbStatement.parameters[":visible"] = pom.visible;       
			
			dbStatement.removeEventListener(SQLEvent.RESULT, onDBStatementSelectResult);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
        }
	
	
		public function remove(pom:Pomodoro):void
		{
			var sqlDelete:String = "delete from Pomodoro where id='"+pom.id+"';";
			dbStatement.text = sqlDelete;
			dbStatement.removeEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}
		
		public function markDone(pom:Pomodoro):void
		{
			var sqlMarkDone:String = "update Pomodoro set done = "+pom.done+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function updateVisibility(pom:Pomodoro):void
		{
			var sqlMarkDone:String = "update Pomodoro set visible = "+pom.visible+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increasePomodoroCount(pom:Pomodoro):void
		{
			trace("Increase DB Pomoodor count: "+pom.pomodoros);
			pom.pomodoros++;
			var sqlMarkDone:String = "update Pomodoro set pomodoros = "+pom.pomodoros+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increaseInterruptionCount(pom:Pomodoro):void
		{
			pom.interruptions++;
			var sqlMarkDone:String = "update Pomodoro set interruptions = "+pom.interruptions+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
		
		public function increaseUnplannedCount(pom:Pomodoro):void
		{
			pom.unplanned++;
			var sqlMarkDone:String = "update Pomodoro set unplanned = "+pom.unplanned+" where id='"+pom.id+"';";
			dbStatement.text = sqlMarkDone;
			dbStatement.addEventListener(SQLEvent.RESULT, onDBStatementInsertResult);
			dbStatement.execute();
		}		
	}
	
}