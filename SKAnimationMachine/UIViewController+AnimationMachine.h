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
@property NSString *fromStateId;
@property NSString *toStateId;
@property NSTimeInterval duration;
@property NSTimeInterval delay;
@property UIViewAnimationCurve animationCurve;

@end

@interface SKState : NSObject

@property NSString *stateId;
@property UIView *animatedView;
@property CGFloat alpha;
@property CGRect frame;
@property CGAffineTransform transform;
@property NSMutableDictionary *transitions;
@property NSString *nextStateId;

@end

@interface SKHelper : NSObject

@property SKState *currentState;

@end

@interface UIViewController (AnimationMachine)

@property SKState *currentState;
@property NSMutableDictionary *states;

- (void)addState:(SKState *)state;
- (void)addTransition:(SKTransition *)transition;

- (void)initialize:(NSString *)state;
- (void)makeTransitionToState:(NSString *)state;

@end
