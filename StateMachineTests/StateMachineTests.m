//
//  Created by Adrian Wiecek.
//  Copyright (c) 2012 Adrian Wiecek. All rights reserved.
//

#import "StateMachineTests.h"
#import "StateMachine.h"
#import "SimpleState.h"

@implementation StateMachineTests
{
    StateMachine *stateMachine;
    SimpleState *state1;
    SimpleState *state2;
}
- (void)setUp
{
    [super setUp];

    state1 = [[SimpleState alloc] initWithName:@"State1"];
    state2 = [[SimpleState alloc] initWithName:@"State2"];
}

- (void)tearDown
{
    [state1 release];
    [state2 release];

    [stateMachine release];
    stateMachine = nil;

    [super tearDown];
}

#pragma mark - init tests

- (void)testInit
{
    stateMachine = [[StateMachine alloc] init];

    STAssertNil([stateMachine initialState], @"Initial state is not nil, initialState: %@", [[stateMachine initialState] name]);
    STAssertNil([stateMachine currentState], @"Current state is not nil, currentState: %@", [[stateMachine currentState] name]);
}

- (void)testInitWithStates
{
    int len = 3;
    SimpleState *state;
    NSMutableArray *states = [[NSMutableArray alloc] init];
    for (int i = 0; i < len; i++)
    {
        state = [[SimpleState alloc] initWithName:[NSString stringWithFormat:@"State %i", i]];
        [states addObject:state];
    }

    stateMachine = [[StateMachine alloc] initWithStates:states];

    STAssertNil([stateMachine initialState], @"Initial state is not nil, initialState: %@", [[stateMachine initialState] name]);
    STAssertNil([stateMachine currentState], @"Current state is not nil, currentState: %@", [[stateMachine currentState] name]);
    STAssertTrue([stateMachine statesCount] == 3, @"States count should be 3");
    STAssertTrue([stateMachine transitionsCount] == 0, @"Transitions count should be 0");

    for (state in states)
    {
        [state release];
        state = nil;
    }
    [states release];
}

- (void)testInitWithStatesWithNilArray
{
    stateMachine = [[StateMachine alloc] initWithStates:nil];

    STAssertNil([stateMachine initialState], @"Initial state is not nil, initialState: %@", [[stateMachine initialState] name]);
    STAssertNil([stateMachine currentState], @"Current state is not nil, currentState: %@", [[stateMachine currentState] name]);
    STAssertTrue([stateMachine statesCount] == 0, @"States count should be 0");
    STAssertTrue([stateMachine transitionsCount] == 0, @"Transitions count should be 0");
}

- (void)testInitWithStatesWithEmptyArray
{
    NSArray *states = [[NSArray alloc] init];
    stateMachine = [[StateMachine alloc] initWithStates:states];

    STAssertNil([stateMachine initialState], @"Initial state is not nil, initialState: %@", [[stateMachine initialState] name]);
    STAssertNil([stateMachine currentState], @"Current state is not nil, currentState: %@", [[stateMachine currentState] name]);
    STAssertTrue([stateMachine statesCount] == 0, @"States count should be 0");
    STAssertTrue([stateMachine transitionsCount] == 0, @"Transitions count should be 0");

    [states release];
}

#pragma mark - canSwitchToState tests

- (void)testCanSwitchToState
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];

    for (SimpleState *state in states)
    {
        STAssertFalse([stateMachine canSwitchToState:state], @"Transition to state: %@ is possible", [state name]);
    }

    stateMachine.initialState = state1;

    STAssertTrue([stateMachine canSwitchToState:state2], @"Transition to state: %@ is not possible", [state2 name]);
    STAssertFalse([stateMachine canSwitchToState:state1], @"Transition to state: %@ is possible", [state1 name]);

    [states release];
}

- (void)testCanSwitchToStateWithNonExistentState
{
    SimpleState *nonExistentState = [[SimpleState alloc] initWithName:@"Non Existent"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];

    STAssertFalse([stateMachine canSwitchToState:nonExistentState], @"Transition to state: %@ is possible", [nonExistentState name]);

    [nonExistentState release];
    [states release];
}

- (void)testCanSwitchToStateWithNilState
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];

    STAssertFalse([stateMachine canSwitchToState:nil], @"Transition to nil state is possible");

    [states release];
}

#pragma mark - hasState tests

- (void)testHasState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];

    STAssertTrue([stateMachine statesCount] == 1, @"States count should be 1");
    STAssertTrue([stateMachine hasState:state1], @"State %@ doesn't exist", [state1 name]);
}

- (void)testHasStateWithNilState
{
    stateMachine = [[StateMachine alloc] init];

    STAssertTrue([stateMachine statesCount] == 0, @"States count should be 0");
    STAssertFalse([stateMachine hasState:nil], @"Nil State has been added");
}

#pragma mark - hasTransitionFromState tests

- (void)testHasTransitionFromState
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];

    STAssertTrue([stateMachine statesCount] == 2, @"States count should be 2");
    STAssertTrue([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition was not created");
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Unwanted Transition was created");

    [states release];
}

#pragma mark - addState tests

- (void)testAddState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];

    STAssertTrue([stateMachine statesCount] == 1, @"States count should be 1");
    STAssertTrue([stateMachine hasState:state1], @"State %@ was not added", [state1 name]);
    STAssertFalse([stateMachine hasState:state2], @"State %@ was added", [state2 name]);
}

- (void)testAddStateWithNilState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:nil];

    STAssertTrue([stateMachine statesCount] == 0, @"States count should be 0");
}

- (void)testAddStateWithNilNameState
{
    state1.name = nil;
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];

    STAssertTrue([stateMachine statesCount] == 0, @"States count should be 0");
}

- (void)testAddStateWithExistentState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];
    [stateMachine addState:state1];

    STAssertTrue([stateMachine statesCount] == 1, @"States count should be 1");
}

#pragma mark - removeState tests

- (void)testRemoveState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];

    [stateMachine removeState:state1];

    STAssertTrue([stateMachine statesCount] == 0, @"States count should be 0");
}

- (void)testRemoveStateWithNonExistentState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];

    [stateMachine removeState:state2];

    STAssertTrue([stateMachine statesCount] == 1, @"States count should be 1");
    STAssertTrue([stateMachine hasState:state1], @"State %@ was not added", [state1 name]);
}

- (void)testRemoveStateWithNilState
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];

    [stateMachine removeState:nil];

    STAssertTrue([stateMachine statesCount] == 1, @"States count should be 1");
    STAssertTrue([stateMachine hasState:state1], @"State %@ was not added", [state1 name]);
}

#pragma mark - addTransitionFromState tests

- (void)testAddTransitionFromState
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];

    STAssertTrue([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [states release];
}

- (void)testAddTransitionFromStateTwoWay
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:YES];

    STAssertTrue([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should be possible", [state1 name], [state2 name]);
    STAssertTrue([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should be possible", [state2 name], [state1 name]);

    [states release];
}

- (void)testAddTransitionFromStateWithNonExistentFromState
{
    SimpleState *nonExistentState = [[SimpleState alloc] initWithName:@"Strange"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:nonExistentState toState:state2 twoWay:NO];

    STAssertFalse([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should not be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [nonExistentState release];
    [states release];
}

- (void)testAddTransitionFromStateWithNonExistentToState
{
    SimpleState *nonExistentState = [[SimpleState alloc] initWithName:@"Strange"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:nonExistentState twoWay:NO];

    STAssertFalse([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should not be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [nonExistentState release];
    [states release];
}

- (void)testAddTransitionFromStateWithNonExistentStates
{
    SimpleState *nonExistentState1 = [[SimpleState alloc] initWithName:@"Strange 1"];
    SimpleState *nonExistentState2 = [[SimpleState alloc] initWithName:@"Strange 2"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:nonExistentState1 toState:nonExistentState2 twoWay:NO];

    STAssertFalse([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should not be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [nonExistentState1 release];
    [nonExistentState2 release];
    [states release];
}

#pragma mark - removeTransitionFromState tests

- (void)testRemoveTransitionFromState
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];
    [stateMachine removeTransitionFromState:state1 toState:state2 twoWay:NO];

    STAssertFalse([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should not be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [states release];
}

- (void)testRemoveTransitionFromStateTwoWay
{
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:YES];
    [stateMachine removeTransitionFromState:state1 toState:state2 twoWay:YES];

    STAssertFalse([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should not be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [states release];
}

- (void)testRemoveTransitionFromStateWithNonExistentFromState
{
    SimpleState *nonExistentState = [[SimpleState alloc] initWithName:@"Strange"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];
    [stateMachine removeTransitionFromState:nonExistentState toState:state2 twoWay:NO];

    STAssertTrue([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [nonExistentState release];
    [states release];
}

- (void)testRemoveTransitionFromStateWithNonExistentToState
{
    SimpleState *nonExistentState = [[SimpleState alloc] initWithName:@"Strange"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];
    [stateMachine removeTransitionFromState:state1 toState:nonExistentState twoWay:NO];

    STAssertTrue([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [nonExistentState release];
    [states release];
}

- (void)testRemoveTransitionFromStateWithNonExistentStates
{
    SimpleState *nonExistentState1 = [[SimpleState alloc] initWithName:@"Strange 1"];
    SimpleState *nonExistentState2 = [[SimpleState alloc] initWithName:@"Strange 2"];
    NSMutableArray *states = [[NSMutableArray alloc] initWithObjects:state1, state2, nil];
    stateMachine = [[StateMachine alloc] initWithStates:states];
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:NO];
    [stateMachine removeTransitionFromState:nonExistentState1 toState:nonExistentState2 twoWay:NO];

    STAssertTrue([stateMachine hasTransitionFromState:state1 toState:state2], @"Transition from state: %@ to state: %@ should be possible", [state1 name], [state2 name]);
    STAssertFalse([stateMachine hasTransitionFromState:state2 toState:state1], @"Transition from state: %@ to state: %@ should not be possible", [state2 name], [state1 name]);

    [nonExistentState1 release];
    [nonExistentState2 release];
    [states release];
}

#pragma mark - statesCount tests

- (void)testStatesCount
{
    stateMachine = [[StateMachine alloc] init];
    STAssertTrue([stateMachine statesCount] == 0, @"States count should be equal to 0");
    [stateMachine addState:state1];
    STAssertTrue([stateMachine statesCount] == 1, @"States count should be equal to 1");
    [stateMachine addState:state2];
    STAssertTrue([stateMachine statesCount] == 2, @"States count should be equal to 2");
    [stateMachine removeState:state1];
    STAssertTrue([stateMachine statesCount] == 1, @"States count should be equal to 1");
    [stateMachine removeState:state2];
    STAssertTrue([stateMachine statesCount] == 0, @"States count should be equal to 0");
}

#pragma mark - transitionsCount tests

- (void)testTransitionsCount
{
    stateMachine = [[StateMachine alloc] init];
    [stateMachine addState:state1];
    [stateMachine addState:state2];
    STAssertTrue([stateMachine transitionsCount] == 0, @"Transitions count should be equal to 0");
    [stateMachine addTransitionFromState:state1 toState:state2 twoWay:false];
    STAssertTrue([stateMachine transitionsCount] == 1, @"Transitions count should be equal to 1");
    [stateMachine addTransitionFromState:state2 toState:state1 twoWay:false];
    STAssertTrue([stateMachine transitionsCount] == 2, @"Transitions count should be equal to 2");
    [stateMachine removeTransitionFromState:state1 toState:state2 twoWay:false];
    STAssertTrue([stateMachine transitionsCount] == 1, @"Transitions count should be equal to 1");
    [stateMachine removeTransitionFromState:state2 toState:state1 twoWay:false];
    STAssertTrue([stateMachine transitionsCount] == 0, @"Transitions count should be equal to 0");
    [stateMachine addTransitionFromState:state2 toState:state1 twoWay:true];
    STAssertTrue([stateMachine transitionsCount] == 2, @"Transitions count should be equal to 2");
    [stateMachine removeTransitionFromState:state2 toState:state1 twoWay:true];
    STAssertTrue([stateMachine transitionsCount] == 0, @"Transitions count should be equal to 0");
}


@end
