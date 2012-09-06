//
//  UIViewController+AnimationMachine.m
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import "UIViewController+AnimationMachine.h"

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

- (void)addState:(SKState *)state {

}

- (void)addTransition:(SKTransition *)transition {

}

- (void)initialize:(NSString *)stateId {
    
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
                         if (state.nextStateId != nil) {
                             [self makeTransitionToState:state.nextStateId];
                         } else {
                             //dojavi da si gotov
                         }
                     }];

}



@end
