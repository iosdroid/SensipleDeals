//
//  ViewController.h
//  SensipleDeals
//
//  Created by Muthupalaniappan S on 09/06/16.
//  Copyright © 2016 sensiple. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationService.h"
@interface ViewController : UIViewController{
    CLPlacemark *placeMark;
    CLLocation *currentLocation;
    CLGeocoder *reverseGeocoder;
}
@property(nonatomic,retain)CLPlacemark *placeMark;
@property(nonatomic,retain) CLLocation *currentLocation;
@property (weak, nonatomic) IBOutlet UILabel *offerMsgLbl;

@end

