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
@property NSString *fromStateId;
@property NSTimeInterval duration;
@property NSTimeInterval delay;
@property UIViewAnimationCurve animationCurve;

@end

@interface SKView : NSObject

@property NSString *animatedViewTag;
@property CGFloat alpha;
@property CGRect frame;
@property CGAffineTransform transform;

@end

@interface SKState : NSObject

@property NSMutableArray *views;
@property NSString *stateId;
@property NSMutableDictionary *transitions;
@property NSString *nextTransition;

- (void)addTransition:(SKTransition *)transition;
- (void)addView:(SKView *)view;

@end

@protocol AnimationMachineProtocol <NSObject>
- (void)movedFromState:(NSString *)fromStateId toState:(NSString *)toStateId onMachine:(NSString *)machine;
- (void)finishedAnimationFromState:(NSString *)fromState toState:(NSString *)stateId onMachine:(NSString *)machine;
@end

@interface UIViewController (AnimationMachine)

@property NSMutableDictionary *currentState;
@property NSMutableDictionary *machines;
@property id<AnimationMachineProtocol> animationDelegate;

- (void)addState:(SKState *)state toMachine:(NSString *)machine;
- (void)initialize:(NSString *)state onMachine:(NSString *)machine;
- (void)performTransition:(NSString *)transitionId onMachine:(NSString *)machine;
- (void)goToState:(NSString *)stateId withTransition:(SKTransition *)transition onMachine:(NSString *)machine;
- (void)stopAnimationsOnMachine:(NSString *)machine;
- (void)initializeAnimationStateMachine;

@end
