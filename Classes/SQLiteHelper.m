//
//  SQLiteHelper.m
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import "SQLiteHelper.h"
#import "Constants.h"
#import "MiscHelper.h"

@implementation SQLiteHelper
@synthesize database;

// The database is stored in the application bundle. 
- (NSString *) sqliteDataFilePath
{
	//NSString *path = [[NSBundle mainBundle] pathForResource:@"date" ofType:@"dat"];
	
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:kSQLiteFileName];
#if TARGET_IPHONE_SIMULATOR
	NSLog(@"%@", path);
#endif
	
	return path;
}

// Open the database connection and retrieve minimal information for all objects.
- (void) initializeDatabase
{
    // Open the database. The database was prepared outside the application.	
    if (sqlite3_open([[self sqliteDataFilePath] UTF8String], &database) != SQLITE_OK) {
        sqlite3_close(database);
        NSAssert1(0, @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
}

- (void) closeDatabase
{
	// Close the database.
    if (sqlite3_close(database) != SQLITE_OK) {
        NSAssert1(0, @"Error: failed to close database with message '%s'.", sqlite3_errmsg(database));
    }
}

// Creates a writable copy of the bundled default database in the application Documents directory.
- (void)createEditableCopyOfDatabaseIfNeeded
{
	[MiscHelper copyFileToSystemDir:kSQLiteFileName];
}

- (void)vacuumDataBase
{
	//const char *sql = "BEGIN;VACUUM;COMMIT;";
	//sqlite3_exec(database, sql, 0, 0, 0);

	sqlite3_stmt *statement;
	
	static char *sql = "VACUUM";
	if (sqlite3_prepare_v2(database, sql, -1, &statement, NULL) != SQLITE_OK) {
		NSAssert1(0, @"Error: failed to prepare statement with message '%s'.", sqlite3_errmsg(database));
	}	
	int success = sqlite3_step(statement);
	sqlite3_finalize(statement);
	
	if (success == SQLITE_ERROR) {
		NSAssert1(0, @"Error: failed to VACUUM the database with message '%s'.", sqlite3_errmsg(database));
	}
}
@end
