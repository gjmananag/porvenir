//
//  MyLocationAppDelegate.m
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 Monitoreo. All rights reserved.
//

#import <sys/utsname.h>
#import "MyLocationAppDelegate.h"
#import "Message.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@implementation MyLocationAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
	[[UIApplication sharedApplication] registerForRemoteNotificationTypes:
        (UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
    
    if ( launchOptions != nil )
	{
		NSDictionary* dictionary = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
		if ( dictionary != nil )
		{
			NSLog(@"Launched from push notification: %@", dictionary);
			[self processRemoteNotification:dictionary updateUI:NO];
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
    
    return YES;
}

NSString* machineName()
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    return [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken
{
    UIDevice* device = [UIDevice currentDevice];
	NSUUID* uuid = device.identifierForVendor;
    NSString* udid = [uuid.UUIDString stringByReplacingOccurrencesOfString:@"-" withString:@""];
	
    NSString* token = [deviceToken description];
	token = [token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
	token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString* osv = [[UIDevice currentDevice] systemVersion];
    
    NSLog(@"My udid is: %@", udid);
    NSLog(@"My token is: %@", token);
    NSLog(@"My osv is: %@", osv);

    // TODO Ask the user for phone number
    
    NSURL* url = [NSURL URLWithString:@"http://198.74.54.196/"];
    AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    [httpClient setParameterEncoding:AFFormURLParameterEncoding];
    
    NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                            @"join", @"cmd",
                            [udid copy], @"udid",
                            [token copy], @"token",
                            @"Apple", @"brand",
                            machineName(), @"model",
                            [osv copy], @"os",
                            nil];
    
    NSMutableURLRequest* request = [httpClient requestWithMethod:@"POST"
                                                            path:@"/services/reg"
                                                      parameters:params];

    AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [op setCompletionBlockWithSuccess:^( AFHTTPRequestOperation* operation, id responseObject )
    {
        NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken(): Success %@", operation.responseString);
    }
        failure:^( AFHTTPRequestOperation* operation, NSError* error )
    {
        NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken(): Error: %@", error.localizedDescription);
    }];
    
    [op start];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
	NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication*)application didReceiveRemoteNotification:(NSDictionary*)userInfo
{
	NSLog(@"Received notification: %@", userInfo);
	[self processRemoteNotification:userInfo updateUI:YES];
}

- (void)processRemoteNotification:(NSDictionary*)userInfo updateUI:(BOOL)updateUI
{
	Message* message = [[Message alloc] init];
	message.date = [NSDate date];
    
	if ( updateUI )
	{
    }
    else
	{
    }
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
