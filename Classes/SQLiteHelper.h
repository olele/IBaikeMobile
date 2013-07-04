//
//  SQLiteHelper.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-8.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "sqlite3.h"

@interface SQLiteHelper : NSObject {
	sqlite3 *database;
}

@property (nonatomic) sqlite3 *database;

- (void) initializeDatabase;
- (NSString *) sqliteDataFilePath;
- (void) closeDatabase;
- (void) createEditableCopyOfDatabaseIfNeeded;
- (void) vacuumDataBase;
@end
