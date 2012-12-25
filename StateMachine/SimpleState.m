//
//  Created by Adrian Wiecek.
//  Copyright (c) 2012 Adrian Wiecek. All rights reserved.
//

#import "SimpleState.h"

@implementation SimpleState

@synthesize name;

- (id)initWithName:(NSString *)initName
{
    if (self = [super init])
    {
        name = initName;
    }
    return self;
}

- (void)dealloc
{
    [super dealloc];
    NSLog(@"State released: %@", name);
}

@end
