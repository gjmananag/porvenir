//
//  MyLocationAppDelegate.h
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 1Block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MyLocationAppDelegate : UIResponder <UIApplicationDelegate, CLLocationManagerDelegate>

@property (strong, nonatomic) UIWindow* window;
@property CLLocationManager* locationManager;

- (void)sendPhoneNumber:(NSString *)udid phoneNumber:(NSString *)pn;
- (void)sendVerificationCode:(NSString *)udid verificationCode:(NSString *)vcode;
- (void)getCurrentLocation;
- (BOOL)sendLocation:(CLLocation *)curLocation;

@end
