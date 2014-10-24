//
//  MainViewController.m
//  SOSOMapDemo
//
//  Created by holyenzou on 14/10/23.
//  Copyright (c) 2014年 holyenzou. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController
@synthesize mapView = _mapView;
@synthesize search = _search;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _search = [[QSearch alloc] init];
        _search.delegate = self;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
//    _mapView = [[QMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
    _mapView.delegate = self;
    [_mapView setShowsUserLocation:YES];
    [_search busSearch:@"上海市"
                 start:@"上海南站"
                   end:@"张江高科"
     withBusSearchType:QBusSearchShortCut];
}

- (void)showAlertView:(NSString*)title widthMessage:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView sizeToFit];
    [alertView show];
}

- (void)notifyRouteSearchResult:(QRouteSearchResult *)routeSearchResult
{
    QErrorCode errCode = [routeSearchResult errorCode];
    NSLog(@"get bus res %i",errCode);
    if (errCode == QRouteSearchResultBusList) {
        
        NSMutableString* msg = [[NSMutableString alloc] init];
        [msg appendString:@"start:\n"];
        
        QRouteQueryResultChoice* choice = (QRouteQueryResultChoice*)[routeSearchResult data];
        
        NSInteger count = 0;
        for (QPlaceInfo* info in [choice startList]) {
            
            [msg appendFormat:@"%d.name=%@,address=%@,coor={%lf,%lf}\n",count,
             info.name,info.address,info.coordinate.longitude,info.coordinate.latitude];
            ++count;
        }
        
        [msg appendString:@"end:\n"];
        
        count = 0;
        for (QPlaceInfo* info in [choice endList]) {
            
            [msg appendFormat:@"%d.name=%@,address=%@,coor={%lf,%lf}\n",
             count,info.name,info.address,info.coordinate.longitude,info.coordinate.latitude];
            ++count;
        }
        
        [self showAlertView:@"choice list" widthMessage:msg];
        
        /*
         出现选择列表，可以选取完起终点再进行进一步搜索，类似下述做法
         */
        NSArray* startList = choice.startList;
        NSArray* endList = choice.endList;
        
        if (startList.count > 0 && endList.count > 0 ) {
            [_search busSearchWithLocation:@"北京"
                                     start:  [startList objectAtIndex:0]
                                       end:[endList objectAtIndex:0]
                         withBusSearchType:QBusSearchShortCut];
        }
        
    } else if (errCode == QRouteSearchResultBusResult) {
        
        QRoutePlan* plan = [routeSearchResult data];
        
        QPointAnnotation* pa = [[QPointAnnotation alloc] init];
        pa.coordinate = plan.start.coordinate;
        pa.title = [NSString stringWithFormat:@"起点:%@",plan.start.name];
        [_mapView addAnnotation:pa];
        
        pa = [[QPointAnnotation alloc] init];
        pa.coordinate = plan.end.coordinate;
        pa.title = [NSString stringWithFormat:@"终点:%@",plan.end.name];
        [_mapView addAnnotation:pa];
        
        NSArray* routeList = [plan routeInfoList];
        
        for (QRouteInfoForBus* route in routeList) {
            
            QPolyline* pl = [QPolyline polylineWithCoordinates:route.routeNodeList
                                                         count:route.routeNodeCount];
            [_mapView addOverlay:pl];
            
            _mapView.region = QCoordinateRegionMake( _mapView.centerCoordinate, QCoordinateSpanMake(0.1, 0.1));
            
            break;
        }
    }
}

- (QAnnotationView *)mapView:(QMapView *)mapView viewForAnnotation:(id <QAnnotation>)annotation
{
    if ([annotation isKindOfClass:[QPointAnnotation class]]) {
        static NSString* reuseIdentifier = @"annotation";
        
        QPinAnnotationView* newAnnotation = (QPinAnnotationView*)[_mapView dequeueReusableAnnotationViewWithIdentifier:reuseIdentifier];
        
        if (nil == newAnnotation) {
            newAnnotation = [[QPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
        }
        
        newAnnotation.pinColor = QPinAnnotationColorRed;
        newAnnotation.animatesDrop = YES;
        newAnnotation.canShowCallout = YES;
        
        return newAnnotation;
    }
    return nil;
}

- (QOverlayView*)mapView:(QMapView *)mapView viewForOverlay:(id<QOverlay>)overlay
{
    if ([overlay isKindOfClass:[QPolyline class]]) {
        
        QPolylineView* polylineView = [[QPolylineView alloc] initWithPolyline:overlay];
        
        polylineView.lineWidth = 2.0;
        polylineView.strokeColor =  [UIColor purpleColor];//[[UIColor redColor] colorWithAlphaComponent:0.5];
        
        return polylineView;
    }
    return nil;
}

- (void)mapViewWillStartLocatingUser:(QMapView *)mapView
{
    //获取开始定位的状态
}

- (void)mapViewDidStopLocatingUser:(QMapView *)mapView
{
    //获取停止定位的状态
}

- (void)mapView:(QMapView *)mapView didUpdateUserLocation:(QUserLocation *)userLocation
{
    //刷新位置
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
