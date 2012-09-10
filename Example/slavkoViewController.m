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
    view.tag = 1;
    [self.view addSubview:view];
    
    UIView *view1 = [[UIView alloc] init];
    view1.backgroundColor = [UIColor redColor];
    view1.frame = CGRectMake(50, 50, 50, 50);
    view1.tag = 2;
    [self.view addSubview:view1];
        
    UIView *view2 = [[UIView alloc] init];
    view2.backgroundColor = [UIColor orangeColor];
    view2.frame = CGRectMake(260, 400, 50, 50);
    view2.tag = 3;
    [self.view addSubview:view2];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(10, 400, 100, 50)];
    [button setTitle:@"Press" forState:UIControlStateNormal];
    button.backgroundColor = [UIColor greenColor];
    [button addTarget:self 
               action:@selector(buttonPressed:) 
     forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

    [self initializeAnimationStateMachineWithDelegate:self];

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self performTransition:@"forward" onMachine:@"machine1"];
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

- (void)buttonPressed:(UIButton *)button{


    if (![self animationRunningOnMachine:@"machine2"]) {
        [self performTransition:@"forward" onMachine:@"machine2"];
    } else {
        [self stopAnimationsOnMachine:@"machine2"];
    }
    
}

- (void)forceStopedAnimationInState:(NSString *)stateId onMachine:(NSString *)machine {
    NSLog(@"State %@ on machine %@", stateId, machine);
}

- (void)movedFromState:(NSString *)fromStateId toState:(NSString *)toStateId onMachine:(NSString *)machine {
    NSLog(@"Moved from %@ to %@ on %@", fromStateId, toStateId, machine);
}

- (void)finishedAnimationFromState:(NSString *)fromState toState:(NSString *)stateId onMachine:(NSString *)machine {
    NSLog(@"Finished from %@ to %@ on %@", fromState, stateId, machine);
}
@end
