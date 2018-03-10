//
//  SQLiteConnect.swift
//  Uchan
//
//  Created by Joyce on 2018/3/7.
//  Copyright © 2018年 Joy. All rights reserved.
//


class SQLiteConnect{
    var db :OpaquePointer? = nil
    let sqlitePath :String
    let dataBase = "SubChannel"
    init?(path :String) {
        sqlitePath = path
        db = self.openDatabase(path: sqlitePath)
        
        if db == nil {
            return nil
        }
    }
    
    // connect database
    func openDatabase(path :String) -> OpaquePointer? {
        var connectdb: OpaquePointer?
        if sqlite3_open(path, &connectdb) == SQLITE_OK {
            print("Successfully opened database \(path)")
        } else {
            print("Unable to open database.")
        }
        return connectdb
    }
    
    // construct SubChannel table
    func createTable() -> Bool {
        let sql = "create table if not exists \(dataBase) (channelid text primary key, title text, thumbnail text, description text, playlistid text)" as NSString
        if sqlite3_exec(self.db, sql.utf8String, nil, nil, nil) == SQLITE_OK{
            return true
        }else{
            return false
        }
    }
    
    // insert
    func insert(channelid:String, title:String, thumbnail:String, description:String, playlistid:String) -> Bool {
        var statement :OpaquePointer? = nil
        let sql = "insert into \(dataBase) (channelid, title, thumbnail, description, playlistid) values ('\(channelid)','\(title)','\(thumbnail)','\(description)','\(playlistid)')" as NSString
        if sqlite3_prepare_v2(self.db, sql.utf8String, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
        }
        return false
    }
    
    func fetchAll()->Array<ChannelDataType>{
        var channelList:Array<ChannelDataType> = []
        let sql = "select * from \(dataBase)"
        var statement :OpaquePointer? = nil
        sqlite3_prepare_v2(self.db, (sql as NSString).utf8String, -1, &statement, nil)
        while sqlite3_step(statement) == SQLITE_ROW{
            let chan = ChannelDataType(
                channelid:  String(cString: sqlite3_column_text(statement, 0)),
                title:  String(cString: sqlite3_column_text(statement, 1)),
                thumbnail:  String(cString: sqlite3_column_text(statement, 2)),
                description:  String(cString: sqlite3_column_text(statement, 3)),
                playlistid:  String(cString: sqlite3_column_text(statement, 4)),
                videoList:  nil,
                nextPageInfo:  nil)
            channelList.append(chan)
        }
        return channelList
    }
    
    // fetch
    func fetch(channelid :String) -> ChannelDataType? {
        var statement :OpaquePointer? = nil
        let sql = "select * from \(dataBase) where channelid='\(channelid)'"
        sqlite3_prepare_v2(self.db, (sql as NSString).utf8String, -1, &statement, nil)
        var chan:ChannelDataType?
        if sqlite3_step(statement) == SQLITE_ROW{
            chan = ChannelDataType(
                channelid:  String(cString: sqlite3_column_text(statement, 0)),
                title:  String(cString: sqlite3_column_text(statement, 1)),
                thumbnail:  String(cString: sqlite3_column_text(statement, 2)),
                description:  String(cString: sqlite3_column_text(statement, 3)),
                playlistid:  String(cString: sqlite3_column_text(statement, 4)),
                videoList:  nil,
                nextPageInfo:  nil)
            }else{
            print("channelid : \(channelid) not found")
        }
        sqlite3_finalize(statement)
        return chan
    }
    
    // 更新資料
    func update( sqlMessage:String) -> Bool {
        var statement :OpaquePointer?

        if sqlite3_prepare_v2(self.db, (sqlMessage as NSString).utf8String, -1,&statement, nil) == SQLITE_OK {
            print("***** sqlite3_step(statement) ***** \(sqlite3_step(statement))")
            if sqlite3_step(statement) == SQLITE_DONE {
                return true
            }
            sqlite3_finalize(statement)
        }
        return false
    }
    
    // delete
    func delete(channelid:String) -> Bool {
        var statement :OpaquePointer?
        let sql = "delete from \(dataBase) where channelid = '\(channelid)'"
        //let sql = "delete from \(dataBase) where channelid="
        print("********** \(sql)")
        if sqlite3_prepare_v2(self.db, (sql as NSString).utf8String, -1, &statement, nil) == SQLITE_OK {
            print("***** sqlite3_step(statement) ***** \(sqlite3_step(statement))")
            //print("***** SQLITE_DONE ***** \(SQLITE_DONE)")
            //print("***** T/F ***** \(sqlite3_step(statement) == SQLITE_DONE)")
            if sqlite3_step(statement) == SQLITE_DONE {
                //print("***** true *****")
                return true
            }
            sqlite3_finalize(statement)
        }
        return false
    }
    
}
