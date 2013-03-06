//
//  MyLocationAppDelegate.h
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 Monitoreo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MyLocationAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow* window;

- (void)sendPhoneNumber:(NSString *)udid phoneNumber:(NSString *)pn;
- (void)sendVerificationCode:(NSString *)udid verificationCode:(NSString *)vcode;

@end
