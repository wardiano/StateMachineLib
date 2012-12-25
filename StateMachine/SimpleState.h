//
//  Created by Adrian Wiecek.
//  Copyright (c) 2012 Adrian Wiecek. All rights reserved.
//

#import "Identifying.h"

@interface SimpleState : NSObject <Identifying>

@property(strong) NSString *name;

- (id)initWithName:(NSString *)initName;

@end
