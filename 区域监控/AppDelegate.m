//
//  AppDelegate.m
//  区域监控
//
//  Created by 李亮 on 15/11/1.
//  Copyright © 2015年 李亮. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

/*
 如果程序开启了一个后台网络任务（通过backgroundSessionConfiguration），在任务完成之前，程序被关闭了，那么后台任务会在另外的进程继续执行。当后台任务执行完毕，或者收到验证消息之后，系统会重启我们的应用程序，把应用程序置为background状态，并且调用下面这个方法，告诉我们根据指定的identifier创建一个backgroundSession，然后系统会自动把后台任务关联到这个session，并且通过session的代理方法处理后台任务的相关事件。
 
 如果当任务完成，或者收到验证消息时，程序正处于suspended状态，系统不会调用这个方法。因为此时，创建任务的session并没有被释放（因为任务没完成），会继续使用原来的session的代理方法处理后台任务的相关事件。
 
 如果任务下载完成之前，程序被关闭了。但是在在下载完成前，用户又打开了这个程序，此时程序也要记录未完成到session任务，并且在启动之后重新创建identifier相同的session并且设置代理，此时，系统会自动把后台session关联到我们重新创建的这个identifier相同的session，并且使用这个session的代理处理后台任务的相关事件。
 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    NSLog(@"%s", __FUNCTION__);
    [self makeNotification:@"handleEventsForBackgroundURLSession" fireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    /*
     这个方法中，我们并没有根据identifier创建session，因为当系统重新启动应用程序时，viewController的viewDidLoad方法会被调用，而viewDidLoad方法中会创建session。而且handleEventsForBackgroundURLSession方法传过来的identifier实际上就是viewDidLoad方法中创建session时使用的identifier。
     
     这里只需要保存completionHandler，在适当的时机执行一下改block，告诉系统，可以更新应用程序的快照了。
     */
    self.backgroundSessionCompletionHandler = completionHandler;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge  |UIUserNotificationTypeSound |UIUserNotificationTypeAlert  categories:nil];
    
    [[UIApplication sharedApplication]registerUserNotificationSettings:settings];
    
    NSLog(@"didFinishLaunchingWithOptions");
    [self makeNotification:@"application:didFinishLaunchingWithOptions" fireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    NSLog(@"%s",__func__);
    [self makeNotification:@"applicationWillResignActive" fireDate:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    NSLog(@"%s",__func__);
    [self makeNotification:@"applicationDidEnterBackground" fireDate:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    NSLog(@"%s",__func__);
    [self makeNotification:@"applicationWillEnterForeground" fireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    NSLog(@"%s",__func__);
    [self makeNotification:@"applicationDidBecomeActive" fireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    NSLog(@"%s",__func__);
    [self makeNotification:@"applicationWillTerminate" fireDate:nil];
}


-(void)applicationDidReceiveMemoryWarning:(UIApplication *)application
{
    NSLog(@"%s",__func__);
    [self makeNotification:@"applicationDidReceiveMemoryWarning" fireDate:nil];
}

-(void)makeNotification:(NSString *)content fireDate:(NSDate *)date
{
    //1.创建本地通知
    UILocalNotification *local = [[UILocalNotification alloc]init];
    
    // 5秒之后触发一个本地通知
    if (date) {
        
        local.fireDate = date;
    }
    
    local.alertBody = content;
    
    local.soundName = @"UILocalNotificationDefaultSoundName";
    
    local.alertLaunchImage = @"msg_img";
    
    //local.applicationIconBadgeNumber = 10;
    
    local.hasAction = YES;
    
    local.alertAction = @"显示tongzhi";
    
    local.userInfo = @{@"name" : @"李亮" , @"QQ":@"222",@"info":@"信息!"};
    //2.定制通知
    //[[UIApplication sharedApplication]scheduleLocalNotification:local];
    
    //取消所有
    //[[UIApplication sharedApplication]cancelAllLocalNotifications];
    //立即推送通知
    if (date) {
        [[UIApplication sharedApplication]scheduleLocalNotification:local];
    }else {
        [[UIApplication sharedApplication]presentLocalNotificationNow:local];
    }
}

@end
