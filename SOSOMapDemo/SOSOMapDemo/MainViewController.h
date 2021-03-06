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
#import "QRouteSearch.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "RouteCell.h"

@interface MainViewController : UIViewController<QSearchDelegate, QMapViewDelegate, QReverseGeocoderDelegate,CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    QPlaceInfo          *_destinationPlaceInfo;
    //CLLocationCoordinate2D  _destinationCoord;
    IBOutlet QMapView   *_mapView;
    QSearch             *_search;
    QReverseGeocoder    *_reverseGeocoder;
    QPlaceInfo          *_userLocationPlaceInfo;
    
    QRoutePlan          *_routePlan;

    NSMutableArray      *_routeInfoForBussArray; //QRouteInfoForBus
    
    QPolyline           *_polyline;
    
}

@property (strong, nonatomic) CLLocationManager *locationManager;


@property(nonatomic, retain) IBOutlet QMapView* mapView;
@property(nonatomic, retain) QSearch* search;
- (IBAction)myPositionButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *placeNameLabel;
- (IBAction)leftBackButtonTap:(id)sender;
- (IBAction)locateButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UIView *bottomView;
- (IBAction)showExtandButtonTap:(id)sender;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end
