//
//  InstanceGroupSetDataController.h
//  SimpleDrillDown
//
//  Created by Eugene Marinelli on 12/18/08.
//  Copyright 2008 Carnegie Mellon University. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AWSAccount.h"

@interface InstanceGroupSetDataController : NSObject {
  AWSAccount* account;
  NSMutableArray *list;
}

- (unsigned)countOfList;
- (id)objectInListAtIndex:(unsigned)theIndex;
@property (nonatomic, copy, readwrite) NSMutableArray *list;
@property (nonatomic, copy, readwrite) AWSAccount *account;
- (void)requestAccountInstanceGroups;
- (id)init:(AWSAccount*)acct;

@end
