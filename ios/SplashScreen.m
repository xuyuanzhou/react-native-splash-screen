/**
 * SplashScreen
 * 启动屏
 * from：http://www.devio.org
 * Author:CrazyCodeBoy
 * GitHub:https://github.com/crazycodeboy
 * Email:crazycodeboy@gmail.com
 */

#import "SplashScreen.h"
#import <React/RCTBridge.h>
#import <UIKit/UIKit.h>

//判断设备型号
#define UI_IS_LANDSCAPE         ([UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeLeft || [UIDevice currentDevice].orientation == UIDeviceOrientationLandscapeRight)
#define UI_IS_IPAD              ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define UI_IS_IPHONE            ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
#define UI_IS_IPHONE4           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height < 568.0)
#define UI_IS_IPHONE5           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define UI_IS_IPHONE6           (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define UI_IS_IPHONE6PLUS       (UI_IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0 || [[UIScreen mainScreen] bounds].size.width == 736.0) // Both orientations
#define UI_IS_IOS8_AND_HIGHER   ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)


static bool waiting = true;
static bool addedJsLoadErrorObserver = false;
static UIViewController *currentViewController = nil;

@implementation SplashScreen
- (dispatch_queue_t)methodQueue{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE()

+ (void)show {
    if (!addedJsLoadErrorObserver) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(jsLoadError:) name:RCTJavaScriptDidFailToLoadNotification object:nil];
        addedJsLoadErrorObserver = true;
    }
    if(!currentViewController){
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        currentViewController = window.rootViewController;
    }
    while (waiting) {
        NSDate* later = [NSDate dateWithTimeIntervalSinceNow:0.1];
        [[NSRunLoop mainRunLoop] runUntilDate:later];
    }
}

+ (void)hide {
    dispatch_async(dispatch_get_main_queue(),
                   ^{
                       waiting = false;
                       if(currentViewController){
                           UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                           window.rootViewController = currentViewController;
                           currentViewController = nil;
                       }
                   });
}

+ (void) jsLoadError:(NSNotification*)notification
{
    // If there was an error loading javascript, hide the splash screen so it can be shown.  Otherwise the splash screen will remain forever, which is a hassle to debug.
    [SplashScreen hide];
}

RCT_EXPORT_METHOD(hide) {
    [SplashScreen hide];
}

RCT_EXPORT_METHOD(show) {
    if(!currentViewController){
        UIViewController *vc = [[UIViewController alloc] init];
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIImage *image = nil;
        if (UI_IS_IPHONE4) {
            image = [UIImage imageNamed:@"LaunchImage-568h"];
        }else if (UI_IS_IPHONE5) {
            image = [UIImage imageNamed:@"LaunchImage-700-568h"];
        }else if (UI_IS_IPHONE6) {
            image = [UIImage imageNamed:@"LaunchImage-800-667h"];
        }else if (UI_IS_IPHONE6PLUS) {
            image = [UIImage imageNamed:@"LaunchImage-800-Portrait-736h"];
        }else {
            image = [UIImage imageNamed:@"LaunchImage-1100-Portrait-2436h"];
        }
        currentViewController = window.rootViewController;
        if(image){
            vc.view.backgroundColor =  [UIColor colorWithPatternImage:image];
        }else{
            vc.view.backgroundColor = [UIColor greenColor];
        }
        window.rootViewController = vc;
        [SplashScreen show];
    }
}

@end
