package com.pomodairo.db
{
	import com.pomodairo.Pomodoro;
	
	import flash.data.SQLConnection;
	import flash.data.SQLMode;
	import flash.data.SQLResult;
	import flash.data.SQLStatement;
	import flash.events.SQLErrorEvent;
	import flash.events.SQLEvent;
	import flash.filesystem.File;
	
	public class Storage
	{
		[Bindable]
		public var dataset:Array;
			
		private var sqlConnectionFile:File;
		private var sqlConnection:SQLConnection;
		private var dbStatement:SQLStatement;
		
		public function Storage()
		{
		}
		
		public function initAndOpenDatabase():void {       		
			sqlConnectionFile = File.userDirectory.resolvePath("pomodairo.db");
			sqlConnection = new SQLConnection();

			
			// sqlConnection.addEventListener(SQLErrorEvent.ERROR, onSQLConnectionError);
			
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
		 				"done BOOLEAN )";
		 					
		 	q.text = sql;
		 	q.addEventListener( SQLEvent.RESULT, createResult );
		 	q.addEventListener( SQLErrorEvent.ERROR, createError );
		 	q.execute();
		}

		public function getAllPomodoros():void
		{
			trace("Get All Pomodoros");
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
				trace("Got data: "+dataset);
				for each (var pom:Pomodoro in dataset) {
					trace("Got Pom: "+pom.name);
				}
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
        	trace("Add Pomodoro");
        	var sqlInsert:String = "insert into Pomodoro (name, type, pomodoros, unplanned, interruptions, created, closed, done) " + 
        			"values(:name,:type,:pomodoros,:unplanned,:interruptions,:created,:closed,:done);";
        			
			dbStatement.text = sqlInsert;
			dbStatement.parameters[":name"] = pom.name;
			dbStatement.parameters[":type"] = pom.type; 
			dbStatement.parameters[":pomodoros"] = pom.pomodoros; 
			dbStatement.parameters[":unplanned"] = pom.unplanned; 
			dbStatement.parameters[":interruptions"] = pom.interruptions; 
			dbStatement.parameters[":created"] = pom.created; 
			dbStatement.parameters[":closed"] = pom.closed; 
			dbStatement.parameters[":done"] = pom.done;  
			
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
	}
	
}