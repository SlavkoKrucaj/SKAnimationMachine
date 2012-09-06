//
//  UIViewController+AnimationMachine.m
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import "UIViewController+AnimationMachine.h"
#import <objc/runtime.h>

static char CURRENT_STATE;
static char STATES;
static char ANIMATION_DELEGATE;

@implementation SKState

@synthesize stateId;
@synthesize animatedView;
@synthesize alpha;
@synthesize frame;
@synthesize transform;
@synthesize transitions;
@synthesize nextStateId;

@end

@implementation SKTransition

@synthesize transitionId;
@synthesize fromStateId;
@synthesize toStateId;
@synthesize duration;
@synthesize animationCurve;
@synthesize delay;

@end

@implementation SKHelper

@synthesize currentState;

@end

@implementation UIViewController (AnimationMachine)

@dynamic currentState;
@dynamic states;
@dynamic animationDelegate;

- (void)addState:(SKState *)state {
    if (self.states == nil) {
        self.states = [NSMutableDictionary dictionary];
    }
    [self.states setObject:state forKey:state.stateId];

}

- (void)initialize:(NSString *)stateId {
    self.currentState = [self.states objectForKey:stateId];
}

- (void)makeTransitionToState:(NSString *)stateId {
    SKTransition *transition = [self.currentState.transitions objectForKey:stateId];
    SKState *state = [self.states objectForKey:stateId];
    
    [UIView animateWithDuration:transition.duration
                          delay:transition.delay
                        options:transition.animationCurve
                     animations:^{
                         //za sve viewove u stateu postavi frame identity i alpha
                         state.animatedView.frame = state.frame;
                         state.animatedView.alpha = state.alpha;
                         state.animatedView.transform = state.transform;
                     } 
                     completion:^(BOOL finished){

                         self.currentState = state;
                         
                         if (state.nextStateId != nil) {
                             [self makeTransitionToState:state.nextStateId];
                         } else {
                             [self.animationDelegate finishedAnimationToState:stateId];
                         }
                     }];

}

- (SKState *)currentState {
    return objc_getAssociatedObject(self, &CURRENT_STATE);
}

- (void)setCurrentState:(SKState *)_currentState {
    objc_setAssociatedObject(self, &CURRENT_STATE, _currentState, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSMutableDictionary *)states {
    return objc_getAssociatedObject(self, &STATES);
}

- (void)setStates:(NSMutableDictionary *)_states {
    objc_setAssociatedObject(self, &STATES, _states, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<AnimationMachineProtocol>)animationDelegate {
    return objc_getAssociatedObject(self, &ANIMATION_DELEGATE);
}

- (void)setAnimationDelegate:(id<AnimationMachineProtocol>)_animationDelegate {
    objc_setAssociatedObject(self, &ANIMATION_DELEGATE, _animationDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}


@end
