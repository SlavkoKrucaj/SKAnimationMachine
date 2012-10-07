SKAnimationMachine
==================

`SKAnimationStateMachine` is simple category for `UIViewController` which allows you to externalize code for your animations done in that view.

Basic idea was to create state machine for UIView. Basically you can define your states, by specifiying locations of views and its properties in different states in JSON. State definition is done in JSON (structure is explained later). When you have states defined you also define in which states you can go from that state and with what transition.
`SKAnimationStateMachine` supports, normal transformations with all properties duration, list of identityTransforms, frame transformation, alpha. Also it supports sequntial animations, which are animations that have to be doen in one step.

It also has support for having mulitple `SKAnimationMachine`s in one viewController, so you can have parallel animations going on. Also you can define different machines on **iphone and ipad** for the same viewController.

Great thing about this is that it reduces code nedded for animations to few lines.

```objective-c
[self initializeAnimationStateMachineWithDelegate:self];
[self performTransition:@"transitionId" onMachine:@"machineId"];
```


##Usage

`SKAnimationStateMachine` is really simple to use since it is just a category. You just drag `UIViewController+SKAnimationStateMachine.[hm]` to your project and start using it.

###JSON structure

To be able to use this category properly you have to write JSON which defines state mchines. JSON structure is this

```json
[
  {
    "machine": "name of the machine",
    "states": [ //every state coresponds to view positions and transformations
      {
        "stateId": "id of the state",
        "initial": set state as initial state after initialization,
        "views": [ //list of all views this state contains
          {
            "animatedViewTag": "tag of view to be animated",
            "alpha": "alpha of the view",
            "rect": "frame of the view in this state",
            "transformations": [ //list of all transformations from Identity to get to wanted state
              {
                "id": 0
              }
            ]
          },
          {
            "animatedViewTag": "2",
            "alpha": 1,
            "rect": "{{50,50},{50,50}}",
            "transformations": []
          }
        ],
        "transitions": [ // list of all transitions to states where you can get to
          {
            "transitionId": "forward",
            "toStateId": "state2",
            "duration": 1,
            "delay": 0,
            "animationCurve": 2,
            "nextTransitionId": "back"
          }
        ]
      },
      {
        "stateId": "state2",
        "initial": false,
        "views": [
          {
            "animatedViewTag": "1",
            "alpha": 0.5,
            "rect": "",
            "transformations": [
              {
                "id": 3,
                "tx": 0,
                "ty": 200
              },
              {
                "id": 2,
                "sx": 1.2,
                "sy": 1.2
              },
              {
                "id": 1,
                "alpha": 180
              }
            ]
          },
          {
            "animatedViewTag": "2",
            "alpha": 0.2,
            "rect": "{{200,50},{50,50}}",
            "transformations": []
          }
        ],
        "transitions": [
          {
            "transitionId": "back",
            "toStateId": "state1",
            "duration": 0.5,
            "delay": 1,
            "animationCurve": 2,
            "nextTransitionId": "forward"
          }
        ]
      }
    ]
  }
]
```

As you have seen, there are fields `animationCurve`, and transformation `id`. Properties are as follow

```
animationCurve
	0 -> EaseIn
	1 -> EaseOut
	2 -> EaseInOut
	3 -> Linear
```

```
transformationId
	0 -> Identity - this transformation has no properties
	1 -> Rotation - this transformation has property alpha - which is the angle of rotation
	2 -> Scale - it has properties, sx and sy, scale factor on x-axis and scale factor on y-axis respectively
	3 -> Translate - ut has properites, tx and ty
```

###Code

####Naming

After you have the json structure, you have to add JSON to your resources, you name it like this **animation\_className\_[iphone|ipad].json**. So if your class is SKExampleViewController and you use it for iphone, your JSON will be named `animation_SKExampleViewController_iphone.json`.

If you are running your app on ipad and don't have …_ipad.json file it will fallback to iphone file and vice versa.

####Usage
After you have JSON defined, all you have to do next is create views with tags so they match those defined in JSON and then it's just a matter of performing transitions between states.

```objective-c
[self initializeAnimationStateMachineWithDelegate:self];
[self performTransition:@"transitionId" onMachine:@"machineId"];
```

####Delegate
If you want to be notified when animationState has been changed, you just need to implement protocol `SKAnimationMachineProtocol` and do something like this

```objective-c
self.animationDelegate = self;

...

- (void)forceStopedAnimationInState:(NSString *)stateId onMachine:(NSString *)machine {
    NSLog(@"State %@ on machine %@", stateId, machine);
}

- (void)movedFromState:(NSString *)fromStateId toState:(NSString *)toStateId onMachine:(NSString *)machine {
    NSLog(@"Moved from %@ to %@ on %@", fromStateId, toStateId, machine);
}

- (void)finishedAnimationFromState:(NSString *)fromState toState:(NSString *)stateId onMachine:(NSString *)machine {
    NSLog(@"Finished from %@ to %@ on %@", fromState, stateId, machine);
}
```

and you'll be notified whenever some change occurs.

##Future work

Next step in development would be to make a web interface for creating JSON structure, possiblly with live animation preview in your browser.