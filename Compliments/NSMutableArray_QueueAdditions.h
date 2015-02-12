//
//  NSMutableArray_QueueAdditions.h
//  Compliments
//
//  Created by tester on 5/3/14.
//  Copyright (c) 2014 James Phillips. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSMutableArray (QueueAdditions)
- (id) dequeue;
- (void) enqueue:(id)obj;
@end
