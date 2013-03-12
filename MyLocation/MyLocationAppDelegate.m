//
//  MyLocationAppDelegate.m
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 1Block. All rights reserved.
//

#import <sys/utsname.h>
#import "MyLocationAppDelegate.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

#define SVR_URL @"http://198.74.54.196/"
#define VERIFIED @"250"
#define LOCATION 9

@implementation MyLocationAppDelegate

@synthesize locationManager;

-(id)init
{
    self = [super init];
    if ( self ) {
        
        locationManager = [[CLLocationManager alloc] init];
    }
    
    return self;
}

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
        (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if ( launchOptions != nil )
	{
		NSDictionary* userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if ( userInfo != nil )
		{
			NSLog( @"Launched from push notification: %@", userInfo );
			[self processRemoteNotification:userInfo updateUI:NO];
		}
        else
        {
            NSLog(@"Launched from push notification: %@", launchOptions);
        }
	}
    else
    {
        NSLog(@"Launched from push notification: NULL launchOptions");
    }
    
    NSInteger bn = [[UIApplication sharedApplication] applicationIconBadgeNumber];
    if ( bn == LOCATION ) {
   
        [self getCurrentLocation];
        [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    }
    
    return YES;
}

NSString* machineName()
{
    struct utsname systemInfo;
    uname( &systemInfo );
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    UIDevice* device = [UIDevice currentDevice];
	NSUUID* uuid = device.identifierForVendor;
    NSString* udid = [uuid.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
	
    NSString* token = [deviceToken description];
	token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString* model = machineName();
    NSString* osv = [[UIDevice currentDevice] systemVersion];
    
    NSLog(@"My udid is: %@", udid);
    NSLog(@"My token is: %@", token);
    NSLog(@"My model is: %@", model);
    NSLog(@"My osv is: %@", osv);

    NSURL* url = [NSURL URLWithString:SVR_URL];
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"reg", @"cmd",
                            [udid copy], @"udid",
                            [token copy], @"token",
                            @"Apple", @"brand",
                            [model copy], @"model",
                            [osv copy], @"os",
                            nil];
    
    NSMutableURLRequest* request = [httpClient requestWithMethod:@"POST"
                                                            path:@"/services/reg"
                                                      parameters:params];

    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^( AFHTTPRequestOperation* operation, id responseObject )
     {
         NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken(): Success %@", operation.responseString);
         
         // TODO Ask the user for phone number
         
         [self sendPhoneNumber:udid phoneNumber:@"3208486363"];
     }
                              failure:^( AFHTTPRequestOperation* operation, NSError* error )
     {
         NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken(): Error: %@", error.localizedDescription);
    
         UIAlertView* errorAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Error" message:error.localizedDescription delegate:nil
                                    cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [errorAlert show];
     }];
    
    [op start];
}

- (void)sendPhoneNumber:(NSString *)udid
            phoneNumber:(NSString *)pn
{
    NSURL* url = [NSURL URLWithString:SVR_URL];
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"phn", @"cmd",
                            [udid copy], @"udid",
                            [pn copy], @"number",
                            nil];
    
    NSMutableURLRequest* request = [httpClient requestWithMethod:@"POST"
                                                            path:@"/services/reg"
                                                      parameters:params];
    
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^( AFHTTPRequestOperation* operation, id responseObject )
     {
         NSLog(@"sendPhoneNumber(): Success %@", operation.responseString);

         // TODO Ask the user for verification code
         
         [self sendVerificationCode:udid verificationCode:@"011051"];
     }
                              failure:^( AFHTTPRequestOperation* operation, NSError* error )
     {
         NSLog(@"sendPhoneNumber(): Error: %@", error.localizedDescription);
         
         UIAlertView* errorAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Error" message:error.localizedDescription delegate:nil
                                    cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [errorAlert show];
     }];
    
    [op start];
}

- (void)sendVerificationCode:(NSString *)udid
            verificationCode:(NSString *)vcode
{
    NSURL* url = [NSURL URLWithString:SVR_URL];
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"vcc", @"cmd",
                            [udid copy], @"udid",
                            [vcode copy], @"ccode",
                            nil];
    
    NSMutableURLRequest* request = [httpClient requestWithMethod:@"POST"
                                                            path:@"/services/reg"
                                                      parameters:params];
    
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^( AFHTTPRequestOperation* operation, id responseObject )
     {
         NSLog(@"sendVerificationCode(): Success %@", operation.responseString);
         
         if ( [operation.responseString isEqualToString:VERIFIED] ) {
             
             UIAlertView* okAlert = [[UIAlertView alloc]
                                     initWithTitle:@"Message" message:@"Congrats, your phone number has been verified!"
                                     delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [okAlert show];
         }
     }
                              failure:^( AFHTTPRequestOperation* operation, NSError* error )
     {
         NSLog(@"sendVerificationCode(): Error: %@", error.localizedDescription);
         
         UIAlertView* errorAlert = [[UIAlertView alloc]
                                    initWithTitle:@"Error" message:error.localizedDescription
                                    delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
         [errorAlert show];
     }];
    
    [op start];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application
didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	[self processRemoteNotification:userInfo updateUI:YES];
}

- (void)processRemoteNotification:(NSDictionary *)userInfo
                         updateUI:(BOOL)updateUI
{
    NSDictionary* aps = [userInfo objectForKey:@"aps"];
    NSNumber* badge = [aps objectForKey:@"badge"];
    
	if ( badge != nil ) {
        
        if ( [badge integerValue] == LOCATION ) {
            
            [self getCurrentLocation];
        }
    }
    else {
    }
    
	if ( updateUI ) {
    }
    else {
    }
}

- (void)getCurrentLocation {
    
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    // 1st: stop location manager
    [locationManager stopUpdatingLocation];
    
    if ( newLocation != nil ) {
    
        NSLog(@"didUpdateToLocation(new): %@", newLocation);
        
        if ( oldLocation == nil || [newLocation distanceFromLocation:oldLocation] > 10 ) {
        
            [self sendLocation:newLocation];
        }
    }
    else {
        // try again
    }
}

- (BOOL)sendLocation:(CLLocation *)curLocation
{
    BOOL r = TRUE;

    UIDevice* device = [UIDevice currentDevice];
	NSUUID* uuid = device.identifierForVendor;
    NSString* udid = [uuid.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];

    NSString* lon = [NSString stringWithFormat:@"%.15f", curLocation.coordinate.longitude];
    NSString* lat = [NSString stringWithFormat:@"%.15f", curLocation.coordinate.latitude];
    
    NSURL* url = [NSURL URLWithString:SVR_URL];
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"store", @"cmd",
                            [udid copy], @"udid",
                            [lat copy], @"lat",
                            [lon copy], @"lon",
                            nil];
    
    NSMutableURLRequest* request = [httpClient requestWithMethod:@"POST"
                                                            path:@"/services/loc"
                                                      parameters:params];
    
    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^( AFHTTPRequestOperation* operation, id responseObject )
     {
         NSLog(@"locationManager(): Success %@", operation.responseString);
     }
                              failure:^( AFHTTPRequestOperation* operation, NSError* error )
     {
         NSLog(@"locationManager(): Error: %@", error.localizedDescription);
     }];
    
    [op start];
    
    return r;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
