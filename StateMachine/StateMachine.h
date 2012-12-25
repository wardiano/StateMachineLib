//
//  Created by Adrian Wiecek.
//  Copyright (c) 2012 Adrian Wiecek. All rights reserved.
//

#import "Identifying.h"

@interface StateMachine : NSObject

@property(nonatomic, assign) id <Identifying> initialState;
@property(nonatomic, assign) id <Identifying> currentState;

- (id)initWithStates:(id <NSFastEnumeration>)initStates;

- (BOOL)canSwitchToState:(id <Identifying>)state;

- (BOOL)hasState:(id <Identifying>)state;

- (BOOL)hasTransitionFromState:(id <Identifying>)fromState toState:(id <Identifying>)toState;

- (void)addState:(id <Identifying>)state;

- (void)removeState:(id <Identifying>)state;

- (void)addTransitionFromState:(id <Identifying>)fromState toState:(id <Identifying>)toState twoWay:(BOOL)twoWay;

- (void)removeTransitionFromState:(id <Identifying>)fromState toState:(id <Identifying>)toState twoWay:(BOOL)twoWay;

- (NSUInteger)statesCount;

- (NSUInteger)transitionsCount;

@end
