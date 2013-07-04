//
//  MsgBoxHelper.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-13.
//  Copyright 2010 iHomeWiki. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MsgBoxHelper : NSObject {

}

+ (void) showMsgBoxOK:(NSString *)msg fromDeleate:(id)delegate;
+ (void) showMsgBoxOKCancel:(NSString *)msg fromDeleate:(id)delegate;

@end
