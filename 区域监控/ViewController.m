//
//  ViewController.m
//  区域监控
//
//  Created by 李亮 on 15/11/1.
//  Copyright © 2015年 李亮. All rights reserved.
//


/*
 
 连接网络时，区域监控更及时。
 
 CLLocationManager有区域监控范围设置。maximumRegionMonitoringDistance
 
 monitoredRegions 是所有CLLocationManager共享的。
 
 由于区域监控事件被relaunch时，AppDelegate的didFinishLaunchingWithOptions方法传入的dict中包含UIApplicationLaunchOptionsLocationKey
 
 */


#import "ViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "AppDelegate.h"

@interface ViewController () <CLLocationManagerDelegate,MKMapViewDelegate,NSURLSessionDataDelegate,NSURLSessionDownloadDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *myLocation;
@property (strong, nonatomic) NSDate *lastLocationNotificationDate;
@property (strong, nonatomic) NSDate *lastMonitorNotificationDate;
@property (strong, nonatomic) NSURLSession *session;
@property (strong, nonatomic) NSURLSession *backgroundSession;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) NSURLSessionTask *task;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CLLocationManager *locationManager = [CLLocationManager new];
    locationManager.delegate = self;
    self.locationManager = locationManager;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    

    
    self.lastLocationNotificationDate = [NSDate date];
    self.lastMonitorNotificationDate = [NSDate date];
    
    [self backgroundSession];
    
    NSLog(@"view did load");
    [self makeNotification:@"view did load" fireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (IBAction)btn1Clicked:(id)sender {
    
    if ([CLLocationManager locationServicesEnabled]) {
        NSLog(@"location services enabled");
        if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
            [self.locationManager requestAlwaysAuthorization];
        }
        if ([CLLocationManager isMonitoringAvailableForClass:[CLCircularRegion class]]) {
            NSLog(@"monitor region enabled");
        }
        
        self.mapView.showsUserLocation = YES;
        self.mapView.userTrackingMode = MKUserTrackingModeFollow;
        
        if (self.switchView.on && [CLLocationManager significantLocationChangeMonitoringAvailable]) {
            NSLog(@"significantLocationChangeEnabled");
            [self.locationManager stopUpdatingLocation];
            [self.locationManager stopMonitoringSignificantLocationChanges];
            [self.locationManager startMonitoringSignificantLocationChanges];
        }else {
            [self.locationManager stopMonitoringSignificantLocationChanges];
            [self.locationManager stopUpdatingLocation];
            [self.locationManager startUpdatingLocation];
        }
        
        
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:@"北京市中关村" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            for (CLPlacemark *placemark in placemarks) {
                
                NSLog(@"%@_%@",placemark.location,placemark.name);
            }
        }];
//
        [geocoder geocodeAddressString:@"北京市海淀区北辰机械厂" completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
            CLPlacemark *placemark = placemarks.firstObject;
            NSLog(@"%@_%@",placemark.location,placemark.name);
        }];
    }
}

- (IBAction)btn2Clicked:(id)sender {

    //模拟器模拟的位置
//    CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(37.334526,-122.037833);
//    CLLocationCoordinate2D center2 = CLLocationCoordinate2DMake(37.332826,-122.061314);
//    CLLocationCoordinate2D center3 = CLLocationCoordinate2DMake(37.333639,-122.073465);
//    CLLocationCoordinate2D center4 = CLLocationCoordinate2DMake(37.335739,-122.081107);
//    CLLocationCoordinate2D center5 = CLLocationCoordinate2DMake(37.340149,-122.088240);
//    CLLocationCoordinate2D center6 = CLLocationCoordinate2DMake(37.342496,-122.092465);
    
    //北辰机械厂
    CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(40.057335, 116.362653);
    CLLocationCoordinate2D center2 = CLLocationCoordinate2DMake(40.057435, 116.362653);
    CLLocationCoordinate2D center3 = CLLocationCoordinate2DMake(40.057335, 116.362753);
    CLLocationCoordinate2D center4 = CLLocationCoordinate2DMake(40.057535, 116.362653);
    CLLocationCoordinate2D center5 = CLLocationCoordinate2DMake(40.057335, 116.362853);
    CLLocationCoordinate2D center6 = CLLocationCoordinate2DMake(40.057135, 116.362653);
    
    //上班路上
    CLLocationCoordinate2D zgcSOHO = CLLocationCoordinate2DMake(39.982488,116.303631);
    CLLocationCoordinate2D yuxinSubway = CLLocationCoordinate2DMake(40.066124,116.353997);
    CLLocationCoordinate2D yongtaizhuang = CLLocationCoordinate2DMake(40.043692,116.361159);
    CLLocationCoordinate2D lincuiqiao = CLLocationCoordinate2DMake(40.027995,116.378905);
    CLLocationCoordinate2D senlingongyuan = CLLocationCoordinate2DMake(40.016211,116.399036);
    CLLocationCoordinate2D beitucheng = CLLocationCoordinate2DMake(39.983255,116.400663);
    CLLocationCoordinate2D mudanyuan = CLLocationCoordinate2DMake(39.982371,116.376446);
    CLLocationCoordinate2D zhichunli = CLLocationCoordinate2DMake(39.982061,116.336091);
    CLLocationCoordinate2D haidianhuangzhuang = CLLocationCoordinate2DMake(39.981865,116.324348);
    CLLocationCoordinate2D zhongguancun = CLLocationCoordinate2DMake(39.989956,116.323066);
    
    
  
    
    CLCircularRegion *monitorRegion1 = [[CLCircularRegion alloc] initWithCenter:center1 radius:5 identifier:@"myregion1"];
    CLCircularRegion *monitorRegion2 = [[CLCircularRegion alloc] initWithCenter:center2 radius:5 identifier:@"myregion2"];
    CLCircularRegion *monitorRegion3 = [[CLCircularRegion alloc] initWithCenter:center3 radius:5 identifier:@"myregion3"];
    CLCircularRegion *monitorRegion4 = [[CLCircularRegion alloc] initWithCenter:center4 radius:5 identifier:@"myregion4"];
    CLCircularRegion *monitorRegion5 = [[CLCircularRegion alloc] initWithCenter:center5 radius:5 identifier:@"myregion5"];
    CLCircularRegion *monitorRegion6 = [[CLCircularRegion alloc] initWithCenter:center6 radius:5 identifier:@"myregion6"];

    CLCircularRegion *zgcSohuRegion = [[CLCircularRegion alloc] initWithCenter:zgcSOHO radius:100 identifier:@"zgcSohu"];
    CLCircularRegion *yuxinRegion = [[CLCircularRegion alloc] initWithCenter:yuxinSubway radius:400 identifier:@"yuxinSubway"];
    CLCircularRegion *yongtaizRegion = [[CLCircularRegion alloc] initWithCenter:yongtaizhuang radius:400 identifier:@"yongtaizhuangSubway"];
    CLCircularRegion *slgyRegion = [[CLCircularRegion alloc] initWithCenter:senlingongyuan radius:400 identifier:@"senLinGongYuanSubway"];
    CLCircularRegion *lincuiqiaoRegion = [[CLCircularRegion alloc] initWithCenter:lincuiqiao radius:400 identifier:@"lincuiqiao"];
    CLCircularRegion *beituchengRegion = [[CLCircularRegion alloc] initWithCenter:beitucheng radius:400 identifier:@"beiTuCheng"];
    CLCircularRegion *mudanyuanRegion = [[CLCircularRegion alloc] initWithCenter:mudanyuan radius:400 identifier:@"muDanYuan"];
    CLCircularRegion *zhicunliRegion = [[CLCircularRegion alloc] initWithCenter:zhichunli radius:400 identifier:@"zhiCunLi"];
    CLCircularRegion *haidianRegion = [[CLCircularRegion alloc] initWithCenter:haidianhuangzhuang radius:400 identifier:@"haiDianHuangZhuang"];
    CLCircularRegion *zgcRegion = [[CLCircularRegion alloc] initWithCenter:zhongguancun radius:400 identifier:@"zhongGuanCun"];


    [self.locationManager startMonitoringForRegion:monitorRegion1];
    [self.locationManager startMonitoringForRegion:monitorRegion2];
    [self.locationManager startMonitoringForRegion:monitorRegion3];
    [self.locationManager startMonitoringForRegion:monitorRegion4];
    [self.locationManager startMonitoringForRegion:monitorRegion5];
    [self.locationManager startMonitoringForRegion:monitorRegion6];
    
    [self.locationManager startMonitoringForRegion:zgcSohuRegion];
    [self.locationManager startMonitoringForRegion:yuxinRegion];
    [self.locationManager startMonitoringForRegion:yongtaizRegion];
    [self.locationManager startMonitoringForRegion:lincuiqiaoRegion];
    [self.locationManager startMonitoringForRegion:slgyRegion];
    [self.locationManager startMonitoringForRegion:beituchengRegion];
    [self.locationManager startMonitoringForRegion:mudanyuanRegion];
    [self.locationManager startMonitoringForRegion:zhicunliRegion];
    [self.locationManager startMonitoringForRegion:haidianRegion];
    [self.locationManager startMonitoringForRegion:zgcRegion];


}
static NSString *DownloadURLString = @"http://sqdd.myapp.com/myapp/qqteam/AndroidQQ/mobileqq_android.apk";

- (IBAction)startBackgroundDownload:(id)sender {
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionTask *task = [self.backgroundSession downloadTaskWithRequest:request];
    self.task = task;
    [task resume];
}

- (void)startDefaultDownload:(id)sender
{
    NSURL *downloadURL = [NSURL URLWithString:DownloadURLString];
    NSURLRequest *request = [NSURLRequest requestWithURL:downloadURL];
    NSURLSessionTask *task = [self.session downloadTaskWithRequest:request];
    self.task = task;
    [task resume];
}

#pragma mark - location delegate

static int locationUpdateCount = 0;
-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = locations.firstObject;
    if ([location.timestamp timeIntervalSinceNow] > -10) {
//        [self.locationManager stopUpdatingLocation];
        self.myLocation = location;
        NSLog(@"%f,%f",location.coordinate.latitude,location.coordinate.longitude);
        if (locationUpdateCount == 0) {
            
            [self.mapView setCenterCoordinate:location.coordinate animated:NO];
        }
        NSString *strNotification = [NSString stringWithFormat:@"定位：%@_%f_%f",[NSDate date],location.coordinate.latitude,location.coordinate.longitude];
        
        locationUpdateCount++;
        if ([self.lastLocationNotificationDate timeIntervalSinceNow] < -60) {
            [self makeNotification:strNotification fireDate:nil];
            self.lastLocationNotificationDate = [NSDate date];
        }
    }
}



-(void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSString *info = [NSString stringWithFormat:@"区域：%@,enter region %@",[NSDate date],region.identifier];
    NSLog(@"%@",info);
    [self makeNotification:info fireDate:nil];
    
    if (!self.task || self.task.state != NSURLSessionTaskStateRunning) {
        [self startBackgroundDownload:nil];
    }
}

-(void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
    NSString *info = [NSString stringWithFormat:@"区域：%@,exit region %@",[NSDate date],region.identifier];
    NSLog(@"%@",info);
    [self makeNotification:info fireDate:nil];
    
//    if (!self.task || self.task.state != NSURLSessionTaskStateRunning) {
//        [self startDefaultDownload:nil];
//    }

}

-(void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSString *info = [NSString stringWithFormat:@"区域：%@,failed monitor region %@",[NSDate date],region.identifier];
    NSLog(@"%@",info);
    [self makeNotification:info fireDate:nil];
}

//-(void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
//{
//    NSLog(@"start monitor region %@",region.identifier);
//}

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
    
    local.alertAction = @"显示位置信息";
    
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

#pragma mark - lazy load

-(NSURLSession *)session
{
    if (!_session) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        _session = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _session;
}

-(NSURLSession *)backgroundSession
{
    if (!_backgroundSession) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:@"backgroundsession.com.liliang"];
        _backgroundSession = [NSURLSession sessionWithConfiguration:config delegate:self delegateQueue:nil];
    }
    return _backgroundSession;
}

#pragma mark - URLSessionDelegate

-(void)URLSession:(NSURLSession *)session didBecomeInvalidWithError:(NSError *)error
{
    NSString *strNot = [NSString stringWithFormat:@"%@,session invalid",[NSDate date]];
    [self makeNotification:strNot fireDate:nil];
    NSLog(@"%@",strNot);
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if (error) {
        NSString *strNot = [NSString stringWithFormat:@"%@,%@",[NSDate date],error];
        NSLog(@"%@",strNot);
        [self makeNotification:strNot fireDate:nil];
    }else {
        NSString *strNot = [NSString stringWithFormat:@"%@,session complete without error",[NSDate date]];
        NSLog(@"%@",strNot);
        [self makeNotification:strNot fireDate:nil];
    }
}

-(void)URLSessionDidFinishEventsForBackgroundURLSession:(NSURLSession *)session
{
    NSString *strNot = [NSString stringWithFormat:@"%@,URLSessionDidFinishEventsForBackgroundURLSession",[NSDate date]];
    NSLog(@"%@",strNot);
    [self makeNotification:strNot fireDate:nil];
    
    AppDelegate *appDelegate = [UIApplication sharedApplication].delegate;
    if (appDelegate.backgroundSessionCompletionHandler) {
        void (^completionHandler)() = appDelegate.backgroundSessionCompletionHandler;
        appDelegate.backgroundSessionCompletionHandler = nil;
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            completionHandler();
        }];
    }


}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didWriteData:(int64_t)bytesWritten totalBytesWritten:(int64_t)totalBytesWritten totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    static int count = 0;
    NSLog(@"%s", __FUNCTION__);

    double progress = (double)totalBytesWritten / (double)totalBytesExpectedToWrite;
    NSLog(@"DownloadTask: %@ progress: %lf", downloadTask, progress);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.progressView.progress = progress;
    });
    if (count++ % 100 == 0) {
        
        NSString *strNot = [NSString stringWithFormat:@"%d download progress = %f",count,progress];
        [self makeNotification:strNot fireDate:nil];
    }
}

-(void)URLSession:(NSURLSession *)session downloadTask:(NSURLSessionDownloadTask *)downloadTask didFinishDownloadingToURL:(NSURL *)location
{
    NSLog(@"%s", __FUNCTION__);
    [self makeNotification:@"download task finish" fireDate:nil];
}

-(void)dealloc
{
    [self makeNotification:@"dealloc" fireDate:nil];
    [self makeNotification:@"dealloc with fire" fireDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

@end
