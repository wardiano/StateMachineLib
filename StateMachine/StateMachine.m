//
//  Created by Adrian Wiecek.
//  Copyright (c) 2012 Adrian Wiecek. All rights reserved.
//

#import "StateMachine.h"

@implementation StateMachine
{
    NSMutableSet *states;
    NSMutableDictionary *transitions;
}

@synthesize initialState, currentState;

#pragma mark - life cycle

- (id)init
{
    [self initWithStates:nil];
    return self;
}

- (id)initWithStates:(id <NSFastEnumeration>)initStates
{
    if (self = [super init])
    {
        NSLog(@"State Machine created");

        self->states = [[NSMutableSet alloc] init];
        self->transitions = [[NSMutableDictionary alloc] init];

        for (id <Identifying> state in initStates)
        {
            [self addState:state];
        }
    }
    return self;
}

- (void)dealloc
{
    [self removeAllStates];
    [states release];
    states = nil;
    [transitions release];
    transitions = nil;

    [super dealloc];
    NSLog(@"State Machine released");
}

#pragma mark - states

- (void)setCurrentState:(id <Identifying>)state
{
    if ([self canSwitchToState:state])
    {
        currentState = state;
        NSLog(@"Current state changed to: %@", [currentState name]);
    }
    else
    {
        NSLog(@"Can't switch to state: %@", [state name]);
    }
}

- (void)setInitialState:(id <Identifying>)state
{
    if ([self hasState:state])
    {
        currentState = initialState = state;
        NSLog(@"State Machine initialized with state: %@", [currentState name]);
    }
    else
    {
        NSLog(@"Can't set initial state to: %@", [state name]);
    }
}

- (BOOL)canSwitchToState:(id <Identifying>)state
{
    return [self hasState:state] && [self hasTransitionFromState:currentState toState:state];
}

- (BOOL)hasState:(id <Identifying>)state
{
    return [states containsObject:state];
}

- (void)addState:(id <Identifying>)state
{
    if ([state name] == nil) return;
    [states addObject:state];
    NSLog(@"Added state: %@", [state name]);
}

- (void)removeState:(id <Identifying>)state
{
    if ([self hasState:state])
    {
        NSLog(@"Removing all transitions for state: %@", [state name]);
        [self removeTransitionsForState:state];
        [states removeObject:state];
        NSLog(@"Removed state: %@", [state name]);
    }
    else
    {
        NSLog(@"Can't remove state: %@", [state name]);
    }
}

- (NSUInteger)statesCount
{
    return [states count];
}

- (void)removeAllStates
{
    NSMutableSet *statesCopy = [states copy];
    [states removeAllObjects];
    for (id <Identifying> state in statesCopy)
    {
        [self removeState:state];
    }
    [statesCopy release];
}

#pragma mark - transitions

- (BOOL)hasTransitionFromState:(id <Identifying>)fromState toState:(id <Identifying>)toState
{
    NSMutableSet *toTransitions = [transitions objectForKey:[fromState name]];
    return toTransitions != nil ? [toTransitions containsObject:[toState name]] : NO;
}

- (void)addTransitionFromState:(id <Identifying>)fromState toState:(id <Identifying>)toState twoWay:(BOOL)twoWay
{
    if ([self hasState:fromState] && [self hasState:toState])
    {
        [self createTransitionFromState:[fromState name] toState:[toState name]];
        if (twoWay)
        {
            [self createTransitionFromState:[toState name] toState:[fromState name]];
        }
    }
    else
    {
        NSLog(@"Can't create transition from state: %@, to state: %@, two way: %@", [fromState name], [toState name], twoWay ? @"YES" : @"NO");
    }
}

- (void)removeTransitionFromState:(id <Identifying>)fromState toState:(id <Identifying>)toState twoWay:(BOOL)twoWay
{
    [self deleteTransitionFromState:[fromState name] toState:[toState name]];
    if (twoWay)
    {
        [self deleteTransitionFromState:[toState name] toState:[fromState name]];
    }
}

- (void)removeTransitionsForState:(id <Identifying>)forState
{
    [transitions removeObjectForKey:[forState name]];

    for (NSString *fromStateName in [transitions keyEnumerator])
    {
        [self deleteTransitionFromState:fromStateName toState:[forState name]];
    }
}

- (void)createTransitionFromState:(NSString *)fromState toState:(NSString *)toState
{
    NSMutableSet *toTransitions = [transitions objectForKey:fromState];
    if (toTransitions == nil)
    {
        toTransitions = [[NSMutableSet alloc] init];
        [transitions setObject:toTransitions forKey:fromState];
    }
    [toTransitions addObject:toState];
    NSLog(@"Created transition fromState state: %@, to state: %@", fromState, toState);
}

- (void)deleteTransitionFromState:(NSString *)fromState toState:(NSString *)toState
{
    NSMutableSet *toTransitions = [transitions objectForKey:fromState];
    [toTransitions removeObject:toState];
    if ([toTransitions count] == 0)
    {
        [transitions removeObjectForKey:fromState];
        [toTransitions release];
    }
    NSLog(@"Removed transition fromState state: %@, to state: %@", fromState, toState);
}

- (NSUInteger)transitionsCount
{
    return [transitions count];
}

@end
