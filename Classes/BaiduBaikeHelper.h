//
//  BaiduBaikeHelper.h
//  IBaikeMobile
//
//  Created by 李云天 on 10-9-8.
//  Copyright 2010 hxsd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class BaiduBaike;
@class BaiduBaikeCategory;
@class BaiduBaikeRecommend;

@interface BaiduBaikeHelper : NSObject {

}

// http://xx.com?x=%d  =>  http://xx.com?x=1
+ (NSString *) processSearchTermForURL:(NSUInteger)st searchTerm:(NSString *) search;
+ (NSString *) processSearchTermForResultURL:(NSUInteger)st resultsInPage:(NSUInteger)pn searchTerm:(NSString *) search;
// 生成分类下的百科链接
+ (NSString *) processCategoryQuestionsURL:(NSString *)categoryTitle resultsInPage:(NSUInteger)pn;
// 获取分类下的百科链接
+ (NSMutableArray *) fetchCategoryQuestionsURLs:(NSString *)categoryTitle resultsInPage:(NSUInteger)pn;

// 处理余下全文的链接
// <a class="a" href="/question/44088374.html?......">余下全文>></a>
+ (NSString *) stripQuestionMore:(NSString *)html getUrls:(NSMutableArray *)moreUrls;

// 将html的image链接静态化
+ (NSString *)cleanImageTag:(NSString *)html images:(NSMutableArray *)img;

// 清除搜索结果的描红
// <em>北京银行</em> -> 北京银行
+ (NSString *) stripHighlightRedTag:(NSString *)html;

// 从URL中获取百度百科的百科ID
+ (NSString *) getBaiduBaikeId:(NSString *)url;

// 下载知道页面并解析
+ (void) doGetQA:(BaiduBaike *) baiduBaike;

// 保存百科时，处理图片链接，同时将图片保存到系统目录
+ (void)processContentForSavingBaike:(BaiduBaike *)baiduBaike;

// 生成HTML页面
+ (NSString *) makeBaikeWebPage:(BaiduBaike *) baiduBaike withFileName:(NSString *)filename;
// 生成HTML页面
+ (NSString *) makeBaikeAllWebPage:(BaiduBaike *)baiduBaike withFileName:(NSString *)filename;

// 获取精彩推荐
+ (BaiduBaikeRecommend *) fetchRecommendBaike:(sqlite3 *)db;

// 将内容保存到数据库
+ (void) saveBaike:(BaiduBaike *)baiduBaike useDatabase:(sqlite3 *)db;

// 从数据库中删除制定内容
+ (void)deleteBaike:(NSString *)baikeId useDatabase:(sqlite3 *)db;

// 获取所有保存的知道信息
+ (NSMutableArray *)fetchBaikeList:(sqlite3 *)db;
// 获取知道信息
+ (BaiduBaike *)fetchBaike:(NSString *)baikeId useDatabase:(sqlite3 *)db;

// 清空搜索历史
+ (void)clearSearchHistory:(sqlite3 *)db;
// 保存或者更新搜索历史
+ (void)saveOrUpdateSearchHistory:(NSString *)searchText useDatabase:(sqlite3 *)db;

// 保存搜索历史
+ (void)saveSearchHistory:(NSString *)searchText useDatabase:(sqlite3 *)db;

// 获取搜索历史
+ (NSMutableArray *)fetchSearchHistoryList:(sqlite3 *)db;
// 获取搜索历史
+ (NSUInteger)isExistSearchHistory:(NSString *)searchText useDatabase:(sqlite3 *)db;
// 更新搜索历史
+ (void)updateSearchHistory:(NSUInteger)historyId useDatabase:(sqlite3 *)db;

// 获取分类信息
+ (BaiduBaikeCategory *)fetchCategory:(NSUInteger)categoryId useDatabase:(sqlite3 *)db;
+ (NSMutableArray *)fetchCategories:(NSUInteger)parentId useDatabase:(sqlite3 *)db;
+ (NSMutableArray *)fetchCategoryTitles:(NSUInteger)parentId useDatabase:(sqlite3 *)db;

// 获取未找到确切答案的百科列表
+ (NSMutableArray *) fetchBaiduBaikeFromNoAnswer:(NSString *)pageSource useDatabase:(sqlite3 *)db;

// 保存精彩推荐
+ (void )saveRecommend:(BaiduBaikeRecommend *)recommend useDatabase:(sqlite3 *)db;
// 读取精彩推荐
+ (BaiduBaikeRecommend *) fetchRecommend:(NSString *)recommendId useDatabase:(sqlite3 *)db;

// 释放链接
+ (void)finalizeStatements;
@end
