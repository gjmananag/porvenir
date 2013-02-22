//
//  MyLocationViewController.m
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 Monitoreo. All rights reserved.
//

#import "MyLocationViewController.h"

@implementation MyLocationViewController

CLLocationManager* locationManager;
CLGeocoder* geocoder;
CLPlacemark* placemark;
NSMutableURLRequest* request;

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
    
    request = [[NSMutableURLRequest alloc]
               initWithURL:[NSURL
                            URLWithString:@"http://ungrid.unal.edu.co/ls"]];

    [request setHTTPMethod:@"POST"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender {

    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView* errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation* currentLocation = newLocation;
    
    if (currentLocation != nil) {
        
        // stop location manager
        if ( true ) {
            [locationManager stopUpdatingLocation];
        }
        
        _longitudeValue.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.longitude];
        _latitudeValue.text = [NSString stringWithFormat:@"%.8f", currentLocation.coordinate.latitude];

        // reverse geocoding
        if ( false ) {
            NSLog(@"Resolving the Address");
            [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray* placemarks, NSError* error) {
                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                    _addressValue.text = [NSString
                                          stringWithFormat:@"%@ %@\n%@ %@\n%@\n%@",
                                          placemark.subThoroughfare,
                                          placemark.thoroughfare,
                                          placemark.postalCode,
                                          placemark.locality,
                                          placemark.administrativeArea,
                                          placemark.country];
                }
                else {
                    NSLog(@"%@", error.debugDescription);
                }
            } ];
        }
        
        NSString* post = [NSString stringWithFormat:@"cmd=store&lat=%.8f&lon=%.8f",
                          currentLocation.coordinate.latitude, currentLocation.coordinate.longitude];
        NSData* postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString* postLength = [NSString stringWithFormat:@"%d", [postData length]];
        
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        NSURLConnection* conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        if ( conn ) {
            
        }
        else {
            UIAlertView* errorAlert = [[UIAlertView alloc]
                                       initWithTitle:@"Error" message:@"Can't connect to server" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [errorAlert show];
        }
    }
    else {
        
        _longitudeValue.text = @"N/A";
        _latitudeValue.text = @"N/A";
        _addressValue.text = @"N/A";
    }
}

@end
