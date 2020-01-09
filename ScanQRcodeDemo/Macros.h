//
//  Macros.h
//  VideoAndLiveDemo
//
//  Created by GoldenPersimmon on 2019/9/27.
//  Copyright © 2019 GoldenPersimmon. All rights reserved.
//

#ifndef Macros_h
#define Macros_h

#define APPID @"1482896271"//应用id
#define BuglyAppID @"d36a53c8a6"
#define CECAppkey @"1412191018068566#kefuchannelapp75292"
#define CECTenantId @"75292"
#define CECAPNsCerName @""
#define WechatAppid @"wx15a1984de595dd5a"
#define WechatSecret @"4087966e3952f5c66636a882bfb0a6d8"
#define UNIVERSAL_LINK @"https://ios.kuaimapp.com/"
#define JPUSHAppKey @"cac83a3bc633feb28fe769bc"
#define AlipayScheme @"KuaiMangApp"

#define UMAppKey @"5db165024ca357112f00084c"

#define BaseURL [DevelopeEnvironmentManager getBaseUrl]


#define HistoryBundleVersion @"HistoryBundleVersion"

//高效率的NSLog
#ifdef DEBUG
#define DLog(...) NSLog(@"\n%s \n⚠️第%d行⚠️ \n %@\n\n",__func__,__LINE__,[NSString stringWithFormat:__VA_ARGS__])
#else
#define DLog(...)
#endif


//NSError
#define ErrorMsg(text) [NSError errorWithDomain:NSCocoaErrorDomain code:NSURLErrorNotConnectedToInternet userInfo:[NSDictionary dictionaryWithObject:text forKey:NSLocalizedDescriptionKey]]


//获取当前版本号
#define BUNDLE_VERSION [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]
//获取当前版本的biuld
#define BIULD_VERSION [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"]
//获取当前设备的UDID
#define DIV_UUID [[[UIDevice currentDevice] identifierForVendor] UUIDString]
#define BundleID [[NSBundle mainBundle] bundleIdentifier]

//GCD - 延迟执行
#define GCD_AFTER(time,afterBlock) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), afterBlock)
//GCD - 一次性执行
#define GCD_ONCE(onceBlock) static dispatch_once_t onceToken; dispatch_once(&onceToken, onceBlock)
//GCD - 异步主线程
#define GCD_MAIN_QUEUE_ASYNC(mainBlock) dispatch_async(dispatch_get_main_queue(), mainBlock)
//GCD - 异步子线程
#define GCD_GLOBAL_QUEUE_ASYNC(globalBlock) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), globalBlock);


//获取window
#define WIN [UIApplication sharedApplication].delegate.window
//获取通知中心
#define NotificationCenter [NSNotificationCenter defaultCenter]
//NSUserDefaults
#define UserDefaults [NSUserDefaults standardUserDefaults]


//色值
#define RGBA(r,g,b,a) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:a]
#define RGB(r,g,b) RGBA(r,g,b,1.0f)
//CGRectMake
#define Frame(x,y,w,h) CGRectMake(x, y, w, h)
//CGSizeMake
#define Size(w,h) CGSizeMake(w, h)
//UIEdgeInsetsMake
#define Edge(top,left,bottom,right)  UIEdgeInsetsMake(top, left, bottom, right)
//UIImage
#define ImageName(name) [UIImage imageNamed:name]

#define COMMONCOLOR RGB(255, 98, 27)

//一像素
#define OnePixel 1/[UIScreen mainScreen].scale
//状态栏高度
#define StatusBarHeight [UIApplication sharedApplication].statusBarFrame.size.height
//Navigation高度
#define NaviBarHeight [UINavigationBar appearance].frame.size.height
//导航栏高度
#define TopBarHeight (Is_iPhoneX_Series ? 88.f : 64.f)
//标签栏高度
#define TabBarHeight (Is_iPhoneX_Series ? 83.f : 49.f)
/** 屏幕高度 */
#define ScreenH [UIScreen mainScreen].bounds.size.height
/** 屏幕宽度 */
#define ScreenW [UIScreen mainScreen].bounds.size.width


//机型
#define Is_iPhoneXS_Max (ScreenW == 414.f && ScreenH == 896.f)
#define Is_iPhoneX (ScreenW == 375.f && ScreenH == 812.f)
#define Is_iPhone8_Plus (ScreenW == 414.f && ScreenH == 736.f)
#define Is_iPhone8 (ScreenW == 375.f && ScreenH == 667.f)
#define Is_iPhone5 (ScreenW == 320 && ScreenH == 568.f)
#define Is_iPhone5_OR_LESS (ScreenW == 320 && ScreenH <= 568.f)
#define Is_iPhoneX_Series (Is_iPhoneX||Is_iPhoneXS_Max)

#define ISServiceWorkerIdentifier @"ISServiceWorkerIdentifier"//1是
#define ClassVCSelectIndexPathNoti @"ClassVCSelectIndexPathNoti"//ClassVC加载完成后点击首页热门按钮的跳转滚动通知
#define ClassVCIsLoadFinishNoti @"ClassVCIsLoadFinishNoti"//ClassVC加载完成

#define WechatPaySucceedNotification  @"WechatPaySucceedNotification"
#define WechatPayFailNotification  @"WechatPayFailNotification"
#define AliPaySucceedNotification  @"AliPaySucceedNotification"
#define AliPayFailNotification  @"AliPayFailNotification"
#define WechatLoginCodeNotification  @"WechatLoginCodeNotification"
#define WechatShareActionNotification  @"WechatShareActionNotification"
#define CheckLoginVCPOPNotification @"CheckLoginVCPOPNotification"
#define GETUserLoginInfoNotification @"GETUserLoginInfoNotification"
#define GETUserLoginInfoFailNotification @"GETUserLoginInfoFailNotification"
#define UserInfoUpdateNotification @"UserInfoUpdateNotification"
#define ACCOUNT_LOGIN_CHANGED @"ACCOUNT_LOGIN_CHANGED"

#define ClassVCWillSelectSectionKEY @"ClassVCWillSelectSectionKEY"//

#define USERTOKEN [UserDefaults objectForKey:LoginInfoTOKEN]//用户token
#define LoginInfoTOKEN @"LoginInfoTOKEN"//用户token

#define UserGetCoupon @"UserGetCoupon"//用户获得了优惠券没（显示view用）1:领取了 0 没有

#endif /* Macros_h */
