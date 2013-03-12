//
//  MyLocationViewController.h
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 1Block. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MBProgressHUD.h"

@interface MyLocationViewController : UIViewController <CLLocationManagerDelegate, MBProgressHUDDelegate>

@property (weak, nonatomic) IBOutlet UILabel* latitudeValue;
@property (weak, nonatomic) IBOutlet UILabel* longitudeValue;
@property (weak, nonatomic) IBOutlet UILabel* addressValue;

@property CLLocationManager* locationManager;
@property CLGeocoder* geocoder;
@property CLPlacemark* placemark;

- (IBAction)getCurrentLocation:(id)sender;

@end
