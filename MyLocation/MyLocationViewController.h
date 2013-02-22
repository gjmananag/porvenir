//
//  MyLocationViewController.h
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 Monitoreo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MyLocationViewController : UIViewController <CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel* latitudeValue;
@property (weak, nonatomic) IBOutlet UILabel* longitudeValue;
@property (weak, nonatomic) IBOutlet UILabel* addressValue;

- (IBAction)getCurrentLocation:(id)sender;

@end
