//
//  MainViewController.h
//  SOSOMapDemo
//
//  Created by holyenzou on 14/10/23.
//  Copyright (c) 2014年 holyenzou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QMapKit.h"
#import "QSearch.h"

@interface MainViewController : UIViewController<QSearchDelegate, QMapViewDelegate>
{
    IBOutlet QMapView* _mapView;
    QSearch* _search;
}

@property(nonatomic, retain) IBOutlet QMapView* mapView;
@property(nonatomic, retain) QSearch* search;
- (IBAction)myPositionButtonTap:(id)sender;

@end
