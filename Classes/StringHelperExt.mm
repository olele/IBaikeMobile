//
//  StringHelper.h
//  IHomeWiki
//
//  Created by 李云天 on 10-8-24.
//  Copyright 2010 iHomeWiki. All rights reserved.
//
#import <Foundation/Foundation.h>

class StringHelperExt { 
	public: 
		StringHelperExt()
		{
		} 

		static NSInteger alphabeticSort(id string1, id string2, void *reverse)
		{
			if ((*(int *) reverse)) {
				return [string2 localizedCaseInsensitiveCompare:string1];
			}
			else {
				return [string1 localizedCaseInsensitiveCompare:string2];
			}
		}
};