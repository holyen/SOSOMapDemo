//
//  RouteCell.h
//  SOSOMapDemo
//
//  Created by holyenzou on 14/10/28.
//  Copyright (c) 2014年 holyenzou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QRouteSearch.h"

@interface RouteCell : UITableViewCell
{
    UILabel *_routeBusInfoLabel;
    UILabel *_timeDistanceInfoLabel;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style
              reuseIdentifier:(NSString *)reuseIdentifier
              routeInfoForBus:(QRouteInfoForBus *)aQRouteInfoForBus;

@end
