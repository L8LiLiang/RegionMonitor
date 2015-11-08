//
//  AppDelegate.h
//  区域监控
//
//  Created by 李亮 on 15/11/1.
//  Copyright © 2015年 李亮. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (copy) void (^backgroundSessionCompletionHandler)();
@end

