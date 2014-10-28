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
        //_destinationCoord = CLLocationCoordinate2DMake(31.00, 121.24);
        _destinationPlaceInfo = [[QPlaceInfo alloc] init];
        _destinationPlaceInfo.name = @"小茜泾路";
        _destinationPlaceInfo.address = @"上海市松江区";
        _destinationPlaceInfo.coordinate = CLLocationCoordinate2DMake(30.9910130000, 121.2395890000);
        _destinationPlaceInfo.isCity = NO;
        
        _routePlan = [[QRoutePlan alloc] init];
        //创建CLLocationManager对象
        self.locationManager = [[CLLocationManager alloc] init];
        //设置代理为自己
        self.locationManager.delegate = self;
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    //刷新位置
    NSLog(@"userlocation chanage lo=%f,lat= %f",
          newLocation.coordinate.longitude,
          newLocation.coordinate.latitude);
    CLLocationCoordinate2D locationCoordinate2d = CLLocationCoordinate2DMake(newLocation.coordinate.latitude, newLocation.coordinate.longitude);
    _mapView.centerCoordinate = locationCoordinate2d;
    _reverseGeocoder = [[QReverseGeocoder alloc] initWithCoordinate:locationCoordinate2d];
    _reverseGeocoder.delegate = self;
    [_reverseGeocoder start];
}


- (void)viewDidLoad {
    [super viewDidLoad];
//    _mapView = [[QMapView alloc] initWithFrame:CGRectMake(0, 0, 320, 600)];
    NSLog(@"map's width:%f &&& map's height:%f", _mapView.frame.size.width, _mapView.frame.size.height);
    NSLog(@"self.view's widht : %f height : %f", self.view.frame.size.width, self.view.frame.size.height);
    _mapView.delegate = self;
    [_mapView setShowsUserLocation:YES];
    [self.locationManager startUpdatingLocation];
    
    _bottomView.translatesAutoresizingMaskIntoConstraints = YES;
    CGRect bottomViewRect = _bottomView.frame;
    bottomViewRect.origin.y = self.view.frame.size.height - 115;
    _bottomView.frame = bottomViewRect;
    //_routePlan bus
    //[self performSelector:@selector(updateUserLocation) withObject:nil afterDelay:0.5];
}

- (void)updateDestinationInfo
{
    _placeNameLabel.text = [NSString stringWithFormat:@"%@ %@", _destinationPlaceInfo.name, _destinationPlaceInfo.address];
}

- (void)updateUserLocation
{
    [_mapView setShowsUserLocation:YES];
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
    NSLog(@"get bus res %lu",(unsigned long)errCode);
    if (errCode == QBusLineSearchResultBusInfo) {
        id data = [routeSearchResult data];
    } else if (errCode == QRouteSearchResultBusList) {
        
        NSMutableString* msg = [[NSMutableString alloc] init];
        [msg appendString:@"start:\n"];
        
        QRouteQueryResultChoice* choice = (QRouteQueryResultChoice*)[routeSearchResult data];
        
        NSInteger count = 0;
        for (QPlaceInfo* info in [choice startList]) {
            
            [msg appendFormat:@"%ld.name=%@,address=%@,coor={%lf,%lf}\n",(long)count,
             info.name,info.address,info.coordinate.longitude,info.coordinate.latitude];
            ++count;
        }
        
        [msg appendString:@"end:\n"];
        
        count = 0;
        for (QPlaceInfo* info in [choice endList]) {
            
            [msg appendFormat:@"%ld.name=%@,address=%@,coor={%lf,%lf}\n",
             (long)count,info.name,info.address,info.coordinate.longitude,info.coordinate.latitude];
            ++count;
        }
        
        [self showAlertView:@"choice list" widthMessage:msg];
        
        /*
         出现选择列表，可以选取完起终点再进行进一步搜索，类似下述做法
         */
        NSArray* startList = choice.startList;
        NSArray* endList = choice.endList;
        
        if (startList.count > 0 && endList.count > 0 ) {
            [_search busSearchWithLocation:@"上海"
                                     start:_userLocationPlaceInfo
                                       end:_destinationPlaceInfo
                         withBusSearchType:QBusSearchLessTransfer];
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
        
        _routeInfoForBussArray = [plan routeInfoList];
        NSArray* routeList = _routeInfoForBussArray;
        [_tableView reloadData];
        
    }
}

- (void)drawRouteByQRouteInfoForBus:(QRouteInfoForBus *)route
{
    _mapView.region = QCoordinateRegionMake( _mapView.centerCoordinate, QCoordinateSpanMake(0.1, 0.1));

    [_mapView removeOverlay:_polyline];
    _polyline = [QPolyline polylineWithCoordinates:route.routeNodeList
                                             count:route.routeNodeCount];
    [_mapView addOverlay:_polyline];

    NSLog(@"路线选择 : 时间:%d, 路程:%d, 类型:%d, coor:[%f,%f]", route.time, route.distance, route.type,route.routeNodeList->latitude, route.routeNodeList->longitude);
    
    for (QRouteSegmentForBus *busSegment in route.routeSegmentList) {
        NSLog(@"路段信息distance:%lu,endIndex:%ld,name:%@,startIndex:%ld,stationNum:%lu,time:%lu,type:%u,walkDirection:%u,whereGetOff:%@,whereGetOn:%@", (unsigned long)busSegment.distance,(long)busSegment.endIndex,busSegment.name, (long)busSegment.startIndex,(unsigned long)busSegment.stationNum,(unsigned long)busSegment.time,busSegment.type,busSegment.walkDirection,busSegment.whereGetOff,busSegment.whereGetOn);
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
        polylineView.strokeColor =  [UIColor redColor];//[[UIColor redColor] colorWithAlphaComponent:0.5];
        
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
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (IBAction)myPositionButtonTap:(id)sender {
    [self.locationManager startUpdatingLocation];
//    QPointAnnotation* annotation = [[QPointAnnotation alloc]init];
//    [annotation setCoordinate:CLLocationCoordinate2DMake(31.11, 121.59)];
//    [annotation setTitle:@"银科大厦"];
//    [annotation setSubtitle:@"北京市区海淀区苏州街银科大厦"];
    
    //[_mapView addAnnotation:annotation];
//    [_search busSearch:@"上海市"
//                 start:@"上海南站"
//                   end:@"张江高科"
//     withBusSearchType:QBusSearchShortCut];
    //[self updateUserLocation];
}

- (void)reverseGeocoder:(QReverseGeocoder *)geocoder didFindPlacemark:(QPlaceMark *)placeMark
{
    //查询成功时
    QPlaceInfo *placeInfo = [[QPlaceInfo alloc] init];
    placeInfo.name = placeMark.name;
    placeInfo.address = placeMark.address;
    placeInfo.coordinate = placeMark.coordinate;
    //placeInfo.isCity = placeMark.isCity;
    _userLocationPlaceInfo = placeInfo;
    
    [_search busSearchWithLocation:@"上海"
                             start:_userLocationPlaceInfo
                               end:_destinationPlaceInfo
                 withBusSearchType:QBusSearchLessTransfer];
    [self updateDestinationInfo];
    NSLog(@"reverse Geocoder success!");
}

- (void)reverseGeocoder:(QReverseGeocoder *)geocoder didFailWithError:(QErrorCode) error
{
    //查询失败时
    NSLog(@"reverse Geocoder fail!");
}

- (IBAction)leftBackButtonTap:(id)sender {
}

- (IBAction)locateButtonTap:(id)sender {
}
- (IBAction)showExtandButtonTap:(id)sender {
    
    CGRect bottomViewRect = _bottomView.frame;
    bottomViewRect.size.height = 400;
    bottomViewRect.origin.y = self.view.frame.size.height - bottomViewRect.size.height;
    _bottomView.frame = bottomViewRect;
}

#pragma mark - 
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_routeInfoForBussArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"MapViewController.TableView.cell";
    RouteCell *cell = [_tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell = [[RouteCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID routeInfoForBus:[_routeInfoForBussArray objectAtIndex:indexPath.row]];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    QRouteInfoForBus *routeInfoForBus = [_routeInfoForBussArray objectAtIndex:indexPath.row];
    [self drawRouteByQRouteInfoForBus:routeInfoForBus];
}
@end
