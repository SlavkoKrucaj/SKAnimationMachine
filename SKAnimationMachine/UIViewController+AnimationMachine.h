//
//  UIViewController+AnimationMachine.h
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKTransition : NSObject

@property NSString *transitionId;
@property NSString *toStateId;
@property NSTimeInterval duration;
@property NSTimeInterval delay;
@property UIViewAnimationCurve animationCurve;
@property NSString *nextTransitionId;

@end

@interface SKView : NSObject

@property NSString *animatedViewTag;
@property CGFloat alpha;
@property CGRect frame;
@property CGAffineTransform transform;

@end

@interface SKState : NSObject

@property BOOL initial;
@property NSMutableArray *views;
@property NSString *stateId;
@property NSMutableDictionary *transitions;

- (void)addTransition:(SKTransition *)transition;
- (void)addView:(SKView *)view;

@end

@protocol SKAnimationMachineProtocol <NSObject>
- (void)forceStopedAnimationInState:(NSString *)stateId onMachine:(NSString *)machine;
- (void)movedFromState:(NSString *)fromStateId toState:(NSString *)toStateId onMachine:(NSString *)machine;
- (void)finishedAnimationFromState:(NSString *)fromState toState:(NSString *)stateId onMachine:(NSString *)machine;
@end

@interface UIViewController (AnimationMachine)

@property NSMutableDictionary *currentState;
@property NSMutableDictionary *machines;
@property NSMutableDictionary *machineRunning;

@property id<SKAnimationMachineProtocol> animationDelegate;

- (void)addState:(SKState *)state toMachine:(NSString *)machine;
- (void)initialize:(NSString *)state onMachine:(NSString *)machine;
- (void)performTransition:(NSString *)transitionId onMachine:(NSString *)machine;
- (void)goToState:(NSString *)stateId withTransition:(SKTransition *)transition onMachine:(NSString *)machine;
- (void)stopAnimationsOnMachine:(NSString *)machine;
- (void)initializeAnimationStateMachine;
- (void)initializeAnimationStateMachineWithDelegate:(id<SKAnimationMachineProtocol>)delegate;
- (BOOL)animationRunningOnMachine:(NSString *)machine;

@end
