//
//  slavkoViewController.m
//  SKAnimationMachine
//
//  Created by Slavko Krucaj on 6.9.2012..
//  Copyright (c) 2012. slavko.krucaj@gmail.com. All rights reserved.
//

#import "slavkoViewController.h"
#import "UIViewController+AnimationMachine.h"

@interface slavkoViewController ()

@end

@implementation slavkoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor blackColor];
    view.frame = CGRectMake(100, 100, 100, 100);
    [self.view addSubview:view];
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor redColor];
    view1.frame = CGRectMake(50, 50, 50, 50);
    [self.view addSubview:view1];
    
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor orangeColor];
    view2.frame = CGRectMake(260, 400, 50, 50);
    [self.view addSubview:view2];
    
    SKView *anView0 = [[SKView alloc] init];
    anView0.animatedViewId = @"1";
    anView0.animatedView = view;
    anView0.frame = CGRectMake(100, 100, 100, 100);
    anView0.alpha = 1;

    SKView *anView = [[SKView alloc] init];
    anView.animatedViewId = @"2";
    anView.animatedView = view;
    anView.frame = CGRectMake(100, 300, 100, 100);
    anView.alpha = 0.5;
    
    SKView *anView3 = [[SKView alloc] init];
    anView3.animatedViewId = @"3";
    anView3.animatedView = view1;
    anView3.frame = CGRectMake(50, 50, 50, 50);
    anView3.alpha = 0.5;
    
    SKView *anView4 = [[SKView alloc] init];
    anView4.animatedViewId = @"4";
    anView4.animatedView = view1;
    anView4.frame = CGRectMake(200, 50, 50, 50);
    anView4.alpha = 1;
    
    SKView *anView5 = [[SKView alloc] init];
    anView5.animatedViewId = @"5";
    anView5.animatedView = view2;
    anView5.frame = view2.frame;
    anView5.alpha = 0.5;

    SKView *anView6 = [[SKView alloc] init];
    anView6.animatedViewId = @"6";
    anView6.animatedView = view2;
    anView6.frame = CGRectMake(250, 390, 70, 70);
    anView6.alpha = 0.5;
    
    SKTransition *transition = [[SKTransition alloc] init];
    transition.transitionId = @"prijelaz";
    transition.fromStateId = @"state1";
    transition.toStateId = @"state2";
    transition.duration = 2;
    transition.delay = 1;
    transition.animationCurve = UIViewAnimationCurveLinear;
    
    SKTransition *transition1 = [[SKTransition alloc] init];
    transition1.transitionId = @"back";
    transition1.fromStateId = @"state2";
    transition1.toStateId = @"state1";
    transition1.duration = 2;
    transition1.delay = 0;
    transition1.animationCurve = UIViewAnimationCurveLinear;  
    
    SKTransition *transition2 = [[SKTransition alloc] init];
    transition2.transitionId = @"prijelaz";
    transition2.fromStateId = @"state3";
    transition2.toStateId = @"state4";
    transition2.duration = 0.3;
    transition2.delay = 0;
    transition2.animationCurve = UIViewAnimationCurveLinear;
    
    SKTransition *transition3 = [[SKTransition alloc] init];
    transition3.transitionId = @"back";
    transition3.fromStateId = @"state4";
    transition3.toStateId = @"state3";
    transition3.duration = 0.3;
    transition3.delay = 0;
    transition3.animationCurve = UIViewAnimationCurveLinear;
    
    SKState *state = [[SKState alloc] init];
    state.stateId = @"state1";
    [state addView:anView0];
    [state addView:anView3];
    [state addTransition:transition];
    state.nextTransition = @"back";

    SKState *state2 = [[SKState alloc] init];
    state2.stateId = @"state2";
    [state2 addView:anView];
    [state2 addView:anView4];
    [state2 addTransition:transition1];
    state2.nextTransition = @"prijelaz";

    SKState *state3 = [[SKState alloc] init];
    state3.stateId = @"state3";
    [state3 addView:anView5];
    [state3 addTransition:transition2];
    state3.nextTransition = @"back";
    
    SKState *state4 = [[SKState alloc] init];
    state4.stateId = @"state4";
    [state4 addView:anView6];
    [state4 addTransition:transition3];
    state4.nextTransition = @"prijelaz";

    
    [self addState:state toMachine:@"defaultMachine"];
    [self addState:state2 toMachine:@"defaultMachine"];
    
    [self addState:state3 toMachine:@"newMachine"];
    [self addState:state4 toMachine:@"newMachine"];
    
    [self initialize:state.stateId onMachine:@"defaultMachine"];
    [self performTransition:@"prijelaz" onMachine:@"defaultMachine"];
    
    [self initialize:state3.stateId onMachine:@"newMachine"];
    [self performTransition:@"prijelaz" onMachine:@"newMachine"];


	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
