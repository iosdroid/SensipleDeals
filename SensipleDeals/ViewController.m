//
//  ViewController.m
//  SensipleDeals
//
//  Created by Muthupalaniappan S on 09/06/16.
//  Copyright © 2016 sensiple. All rights reserved.
//

#import "ViewController.h"


@interface ViewController ()

@end

@implementation ViewController
@synthesize placeMark ;
@synthesize currentLocation;
- (void)viewDidLoad {
    [super viewDidLoad];
    // placeMark = [[CLPlacemark alloc]init];
    reverseGeocoder = [[CLGeocoder alloc] init];
    
    
    [self getCurrentLocation];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)getCurrentLocation{
    
    [LocationService statrLocation];
    
    [LocationService backgroundForPauseTime:60 locationCounts:5];
    
    [LocationService sharedModel].updateBlock = ^(CLLocation *location) {
        
        self.currentLocation = location;
        
        // NSLog(@"%f",self.currentLocation.coordinate.latitude);
        [reverseGeocoder reverseGeocodeLocation:self.currentLocation completionHandler:^(NSArray *placemarks, NSError *error) {
            placeMark = [placemarks objectAtIndex:0];
            
            //NSLog(@"sel %@",placeMark.subAdministrativeArea);
            
        }];
    };
    
    [LocationService sharedModel].lastBlock = ^(CLLocation *location) {
        // NSLog(@"block backgroundLocation: %f", location.coordinate.latitude);
        NSString *userName = @"ShoppingAdmin";
        NSString *password = @"Shopping@123";
        NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", userName, password];
        NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
        NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
        
        NSLog(@"%@ %@ %@ %@ %@ %@",placeMark.locality,placeMark.subAdministrativeArea,placeMark.administrativeArea,placeMark.subLocality,placeMark.name,placeMark.addressDictionary);
        NSString *baseURL = [NSString stringWithFormat:@"http://192.168.18.210:8088/ShoppingMallApp/rest/location/Chennai/Tamil nadu/India"];
             // NSString *baseURL = [NSString stringWithFormat:@"http://192.168.18.210:8088/ShoppingMallApp/rest/location/Chennai/Tamil nadu/India",placeMark.subAdministrativeArea,placeMark.administrativeArea,placeMark.country];
        NSURL *url = [NSURL URLWithString:[baseURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
        
        NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        [urlRequest addValue:authString forHTTPHeaderField:@"Authorization"];
        
        NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (data) {
                NSArray *myLoc = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                
                
                for (int i=0; i < [myLoc count]; i++) {
                    NSDictionary *locDict = myLoc[i];
                    
                    NSString *lati = locDict[@"latitude"];
                    NSString *longi = locDict[@"longitude"];
                    CLLocationCoordinate2D center =CLLocationCoordinate2DMake([lati doubleValue], [longi doubleValue]);
                    CLLocation *checkinglocation = [[CLLocation alloc] initWithLatitude:center.latitude longitude:center.longitude];
                    
                    double distance = [currentLocation distanceFromLocation:checkinglocation];
                    
                    NSLog(@"Dist %f",distance);
                    if (distance < 170) {
                        NSDictionary *locDict = myLoc[i];
                        NSLog(@"Mall ID %@",locDict[@"mallId"]);
                        [self getAllDeals:locDict[@"mallId"] Mallname:locDict[@"name"]];
                        
                        
                    }
                    
                    
                }
                
                
                
            }
            else{
                NSLog(@"Error Msg %@",error.description);
            }
            
            
        }];
        
        [dataTask resume];
        
    };
    
    
    
    
}

-(void)getAllDeals:(NSString *)mallId Mallname:(NSString *) mallname{
    
    NSString *userName = @"ShoppingAdmin";
    NSString *password = @"Shopping@123";
    NSString *userPasswordString = [NSString stringWithFormat:@"%@:%@", userName, password];
    NSData * userPasswordData = [userPasswordString dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64EncodedCredential = [userPasswordData base64EncodedStringWithOptions:0];
    NSString *authString = [NSString stringWithFormat:@"Basic %@", base64EncodedCredential];
    
    
    NSString *baseURL = [NSString stringWithFormat:@"http://192.168.18.210:8088/ShoppingMallApp/rest/location/%@",mallId];
    NSURL *url = [NSURL URLWithString:[baseURL stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLFragmentAllowedCharacterSet]]];
    
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate: nil delegateQueue: [NSOperationQueue mainQueue]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest addValue:authString forHTTPHeaderField:@"Authorization"];
    
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (data) {
            NSArray *myDeals = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            
            for (int i=0; i < [myDeals count]; i++) {
                NSDictionary *dealsDict = myDeals[i];
                [[UIApplication sharedApplication] cancelAllLocalNotifications];
                
                UILocalNotification *localNotification = [[UILocalNotification alloc] init];
                localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
                localNotification.alertBody = [NSString stringWithFormat:@"%@ have %@",mallname,dealsDict[@"offer"]];
                _offerMsgLbl.text =[NSString stringWithFormat:@"%@ have %@",mallname,dealsDict[@"offer"]];
                localNotification.soundName = UILocalNotificationDefaultSoundName;
                [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
            }
            
            
            
        }
        else{
            NSLog(@"Error Msg %@",error.description);
        }
        
        
    }];
    
    [dataTask resume];
    
}
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    
}

@end
