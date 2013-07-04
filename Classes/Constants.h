/*
 *  Constants.h
 *  IHomeWiki
 *
 *  Created by mantou on 10-8-5.
 *  Copyright 2010 iHomeWiki. All rights reserved.
 *
 */

// 是否是调试模式
#define kDEBUGMODE YES

// 判断用户设备是否是 iPhone 4 Retina 屏
#define isRetina ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)

// 用于数据库升级
// 程序版本：xx.xx.xx，主版本是1～99，次版本是00～99，辅助版本是：00～99
// 因此，最小版本号是：10000，最大是999999
#define kVersion0 10000
#define kVersion1 10100

// Tab
// iPhone版本将搜索结果、搜索历史整合为一个，默认显示搜索历史，搜索后，显示结果
#define kTabBarRecommendedQuestion 0
#define kTabBarSearchHistory 1
#define kTabBarSearchCategory 2
#define kTabBarSavedResult 3
#define kTabBarAbout 4

// UIWebView的内容来源，目前有4个，其中2、3都通过QuestionList显示内容
// 1、精彩推荐
// 2、搜索分类\
//            QuestionList  
// 2、搜索结果/
// 3、保存的资料
// 4、直接搜索获得
typedef enum {
	RecommendQuestions = 1,
	QuestionList = 2,
	SavedResult = 3,
	SearchResult = 4
} UIWebViewContentSource;

// DownloadAndParseWebPage类的下载解析的对象
// 点击“展开全部词条内容”时，获取完整的百科页面
// 搜索时，没有确定答案，返回一个搜索列表供参考
typedef enum {
	BaikePage = 1,
	BaikeSearchResult = 2
} DownloadAndParseSource;

// 数据库文件名
#define kSQLiteFileName @"date.dat"

// 解析百科错误时，提交信息到服务器
#define kReportQuestionURL @"http://ihomewiki.com/reportbug/bug.php?do=baikebug&bkid=%d"

// 提交邮件
#define kReportEmail @"ihomewiki@me.com"

// 保存时，是已经保存，还是保存成功，还是失败
#define kSavedBaikeResultYES 1
#define kSavedBaikeResultNO 2
#define kSavedBaikeResultInDB 9

// 百度百科域名，结尾不含“/”
#define kBaiduBaikeDomain @"http://wapbaike.baidu.com"

// 百科图片链接地址
# define kBaiduBaikeImageURLPath @"http://imgsrc.baidu.com/baike/pic/item/"

// 百度百科移动版参数
# define kBaiduBaikeSTParam 3

// 百度百科知识URL
#define kBaiduBaikeViewURL @"http://wapbaike.baidu.com/view/%@.html?st=%d"
// 这个链接获取完整内容的XML文档
#define kBaiduBaikeAllViewURL @"http://wapbaike.baidu.com/view/%@.html?st=%d&ldr=1"

// 百度百科分类百科URL
#define kBaiduBaikeCategoryQuestionsURL @"http://baike.baidu.com/taglist?tag=%@&offset=%d"

/*
 * 百度百科搜索URL
 *
 * 只取第一页数据
 */
#define kBaiduBaikeSearchURL  @"http://wapbaike.baidu.com/search/?st=%d&word=%@&bd_page_type=1&pu=&ssid=&from="
#define kBaiduBaikeSearchResultURL  @"http://wapbaike.baidu.com/searchresult/?st=%d&word=%@&start=%d&bk_pg_fr=switch_page&bd_page_type=1"

// 每次搜索反馈的结果数量
// 13日之后，这个常量不再使用
// #define kSearchResultsPerPage 25

#define kSearchResultsPerPage0 10
#define kSearchResultsPerPage1 20


