//
//  RouteCell.m
//  SOSOMapDemo
//
//  Created by holyenzou on 14/10/28.
//  Copyright (c) 2014年 holyenzou. All rights reserved.
//

#import "RouteCell.h"

@implementation RouteCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
              routeInfoForBus:(QRouteInfoForBus *)aQRouteInfoForBus
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _routeBusInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 0, self.bounds.size.width - 100, 20)];
        _routeBusInfoLabel.text = @"莲石专线空调 - 地铁1号线 - 地铁8号线";
        [self.contentView addSubview:_routeBusInfoLabel];
        
        _timeDistanceInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 20, self.bounds.size.width - 100, 20)];
        _timeDistanceInfoLabel.text = @"3小时15分钟 | 59.9公里 | 步行 200米";
        [self.contentView addSubview:_timeDistanceInfoLabel];
        [self updateUIByRouteInfoForBus:aQRouteInfoForBus];
    }
    return self;
}

- (void)updateUIByRouteInfoForBus:(QRouteInfoForBus *)route
{
    NSString *timeDistanceStr = [NSString stringWithFormat:@"%ld分钟 | %ld公里", (long)route.time, (long)route.distance];
    NSString *routeBusStr = @"";
    NSLog(@"路线选择 : 时间:%d, 路程:%d, 类型:%d, coor:[%f,%f]", route.time, route.distance, route.type,route.routeNodeList->latitude, route.routeNodeList->longitude);
    
    for (QRouteSegmentForBus *busSegment in route.routeSegmentList) {
        if (busSegment.type == QRouteSegmentTypeWalk) {
            
        } else {
            routeBusStr = [routeBusStr stringByAppendingFormat:@" %@ | ",busSegment.name];
        }
        NSLog(@"路段信息distance:%lu,endIndex:%ld,name:%@,startIndex:%ld,stationNum:%lu,time:%lu,type:%u,walkDirection:%u,whereGetOff:%@,whereGetOn:%@", (unsigned long)busSegment.distance,(long)busSegment.endIndex,busSegment.name, (long)busSegment.startIndex,(unsigned long)busSegment.stationNum,(unsigned long)busSegment.time,busSegment.type,busSegment.walkDirection,busSegment.whereGetOff,busSegment.whereGetOn);
    }
    _timeDistanceInfoLabel.text = timeDistanceStr;
    _routeBusInfoLabel.text = routeBusStr;
}

@end
