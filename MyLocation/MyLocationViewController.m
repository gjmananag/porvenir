//
//  MyLocationViewController.m
//  MyLocation
//
//  Created by Gabriel Mañana on 11/18/12.
//  Copyright (c) 2012 1Block. All rights reserved.
//

#import "MyLocationViewController.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@implementation MyLocationViewController

@synthesize latitudeValue;
@synthesize longitudeValue;
@synthesize addressValue;
@synthesize locationManager;
@synthesize geocoder;
@synthesize placemark;

MBProgressHUD* hud;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    geocoder = [[CLGeocoder alloc] init];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    // Dispose of any resources that can be recreated.
}

- (IBAction)getCurrentLocation:(id)sender {

    hud = [[MBProgressHUD alloc] initWithView:self.view];
    hud.delegate = self;
    hud.labelText = @"Uploading";
	hud.detailsLabelText = @"location data";
    hud.mode = MBProgressHUDModeIndeterminate;
	hud.square = YES;
    
    [self.view addSubview:hud];
    [hud show:YES];
    
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
    
    if ( currentLocation != nil ) {
        
        // stop location manager
        if ( true ) {
            [locationManager stopUpdatingLocation];
        }
        
        longitudeValue.text = [NSString stringWithFormat:@"%.12f", currentLocation.coordinate.longitude];
        latitudeValue.text = [NSString stringWithFormat:@"%.12f", currentLocation.coordinate.latitude];

        // reverse geocoding //////////////////////////////////////////////////////////////////////////////////////////
        if ( false ) {
            NSLog(@"Resolving the Address");
            [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray* placemarks, NSError* error) {
                NSLog(@"Found placemarks: %@, error: %@", placemarks, error);
                if (error == nil && [placemarks count] > 0) {
                    placemark = [placemarks lastObject];
                    addressValue.text = [NSString
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
        // reverse geocoding //////////////////////////////////////////////////////////////////////////////////////////
        
        NSURL* url = [NSURL URLWithString:@"http://ungrid.unal.edu.co"];
        AFHTTPClient* httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        
        [httpClient setParameterEncoding:AFFormURLParameterEncoding];
        
        NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"store", @"cmd",
                                [latitudeValue.text copy], @"lat",
                                [longitudeValue.text copy], @"lon",
                                nil];
        
        NSMutableURLRequest* request = [httpClient requestWithMethod:@"POST"
                                                                path:@"/ls"
                                                          parameters:params];
        
        AFHTTPRequestOperation* op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        [op setCompletionBlockWithSuccess:^( AFHTTPRequestOperation* operation, id responseObject )
         {
             NSLog(@"locationManager(): Success %@", operation.responseString);
             [hud hide:YES];
             
             UIAlertView* okAlert = [[UIAlertView alloc]
                                        initWithTitle:@"Message" message:@"Your location has been successfully stored." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [okAlert show];
         }
                                  failure:^( AFHTTPRequestOperation* operation, NSError* error )
         {
             NSLog(@"locationManager(): Error: %@", error.localizedDescription);
             [hud hide:YES];
             
             UIAlertView* errorAlert = [[UIAlertView alloc]
                                        initWithTitle:@"Error" message:error.localizedDescription delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
             [errorAlert show];
         }];
        
        [op start];
    }
    else {
        
        longitudeValue.text = @"N/A";
        latitudeValue.text = @"N/A";
        addressValue.text = @"N/A";
    }
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	
	[hud removeFromSuperview];
	hud = nil;
}

@end
