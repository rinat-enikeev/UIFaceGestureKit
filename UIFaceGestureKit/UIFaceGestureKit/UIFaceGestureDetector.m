//
//  UIFaceGestureDetector.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 7/21/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureDetector.h"
#import <CoreImage/CoreImage.h>
#import "UIFaceGestureSubscriberDecorator.h"
#import "UIFaceGestureDetectorSettings.h"

@interface UIFaceGestureDetector ()
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) CIDetector *faceDetector;
@property (nonatomic, strong) NSMutableSet* subscriberDecorators;

// atomic
@property BOOL rightEyeClosed;
@property BOOL leftEyeClosed;
@property BOOL bothEyesClosed;
@property BOOL eyesDetected;
@property BOOL smileDetected;

// atomic
@property BOOL detectEyes;
@property BOOL detectSmile;

// atomic
@property NSInteger eyeGesturesSubscribersCount;
@property NSInteger smileGesturesSubscribersCount;

@end

@implementation UIFaceGestureDetector

#pragma mark - Singleton
static UIFaceGestureDetector *sharedInstance = nil;

+ (UIFaceGestureDetector *)sharedDetector
{
    @synchronized(self)
    {
        if (sharedInstance == NULL) {
            sharedInstance = [[self alloc] init];
            TRC_NRM(@"%@ initialized. ", NSStringFromClass([sharedInstance class]));
        }
    }
    return sharedInstance;
}

#pragma mark - Publisher/Subscriber
-(void)addSubscriber:(NSObject<UIFaceGestureSubscriber> *)subscriber
{
    if (!_subscriberDecorators) {
        self.subscriberDecorators = [[NSMutableSet alloc] init];
    }
    
    NSSet* alreadyRegisteredDecoratorsForSubscriber = [_subscriberDecorators objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return [[(UIFaceGestureSubscriberDecorator*)obj subscriber] isEqual:subscriber];
    }];
    
    UIFaceGestureSubscriberDecorator* decorator;
    
    if (alreadyRegisteredDecoratorsForSubscriber == nil || [alreadyRegisteredDecoratorsForSubscriber count] == 0) {
        decorator = [[UIFaceGestureSubscriberDecorator alloc] initWithFaceGestureSubscriber:subscriber];
    } else {
        decorator = [alreadyRegisteredDecoratorsForSubscriber anyObject];
        TRC_ALT(@"Object %@ is already subscribed for face gesture detector events. ", subscriber);
    }

    @synchronized(_subscriberDecorators) {
        [_subscriberDecorators addObject:decorator];
        TRC_NRM(@"%@ subscriber added. ", NSStringFromClass([sharedInstance class]));
    }
    
    [self enableDetectionFor:decorator];

    self.isRunning = YES;
}

-(void)removeSubscriber:(NSObject<UIFaceGestureSubscriber> *)subscriber;
{
    NSSet* alreadyRegisteredDecoratorsForSubscriber = [_subscriberDecorators objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        return [[(UIFaceGestureSubscriberDecorator*)obj subscriber] isEqual:subscriber];
    }];
    
    UIFaceGestureSubscriberDecorator* decorator;
    
    if (alreadyRegisteredDecoratorsForSubscriber == nil || [alreadyRegisteredDecoratorsForSubscriber count] == 0) {
        TRC_ALT(@"WARN: Object %@ was not subscribed for eye gesture detector events. ", subscriber);
    } else {
        decorator = [alreadyRegisteredDecoratorsForSubscriber anyObject];
    }
    
    @synchronized(_subscriberDecorators) {
        [_subscriberDecorators removeObject:decorator];
        TRC_NRM(@"%@ subscriber removed. ", NSStringFromClass([sharedInstance class]));
    }
    
    [self tryDisableDetectionFor:decorator];
    
    if ([_subscriberDecorators count] == 0) {
        self.isRunning = NO;
    }
}

- (void)enableDetectionFor:(UIFaceGestureSubscriberDecorator *)decorator
{
    if (![self detectEyes] && [decorator respondsToEyeGestures]) {
        self.detectEyes = YES;
        self.eyeGesturesSubscribersCount++;
        TRC_NRM(@"%@ subscriber responds to eye gestures. Eye detection enabled. ", [decorator subscriber]);
    }
    if (![self detectSmile] && [decorator respondsToSmileGestures]) {
        self.detectSmile = YES;
        TRC_NRM(@"%@ subscriber responds to smile gestures. Smile detection enabled. ", [decorator subscriber]);
        self.smileGesturesSubscribersCount++;
    }
}

// if number of subscribers for specific type of gestures is zero - disable this type detection
- (void)tryDisableDetectionFor:(UIFaceGestureSubscriberDecorator *)decorator
{
    if (![decorator respondsToEyeGestures] && [self detectEyes]) {
        self.eyeGesturesSubscribersCount--;
        if ([self eyeGesturesSubscribersCount] == 0) {
            self.detectEyes = NO;
            TRC_NRM(@"%@ subscriber was last that responds to eye gestures, eye detection disabled. ", [decorator subscriber]);
        } else if ([self eyeGesturesSubscribersCount] < 0)
        {
            TRC_ERR(@"Number of eye gesture detection subscribers became less than zero");
        }
    }
    
    if (![decorator respondsToSmileGestures] && [self detectSmile]) {
        self.smileGesturesSubscribersCount--;
        if ([self smileGesturesSubscribersCount] == 0) {
            self.detectSmile = NO;
            TRC_NRM(@"%@ subscriber was last that responds to smile gestures, smile detection disabled. ", [decorator subscriber]);
        } else if ([self smileGesturesSubscribersCount] < 0)
        {
            TRC_ERR(@"Number of smile gesture detection subscribers became less than zero");
        }
    }
}

#pragma mark - IsRunnning
-(void)setIsRunning:(BOOL)isRunning
{
    if (_isRunning && !isRunning) {
        [self tearDown];
    } else if (!_isRunning && isRunning) {
        [self setUp];
    }
    _isRunning = isRunning;
}

-(void)setUp
{
	self.faceDetector = [CIDetector detectorOfType:CIDetectorTypeFace
                                     context:nil
                                      options:@{CIDetectorAccuracy:[[UIFaceGestureDetectorSettings sharedSettings] detectorAccuracy]}];
    [[AVVideoSteamSource sharedSource] addSubscriber:self];
    TRC_NRM(@"Started face gestures capture. ");
}

-(void)tearDown
{
    [[AVVideoSteamSource sharedSource] removeSubscriber:self];
    self.faceDetector = nil;
    TRC_NRM(@"Stopped face gestures capture. ");
}

#pragma mark - AVVideoSteamSourceSubscriber
-(void)videoStreamSource:(AVVideoSteamSource *)videoStreamSource capturedImage:(CIImage *)image inOrientation:(NSNumber *)imageOrientation
{
    NSArray* features = [_faceDetector featuresInImage:image
                                       options:@{CIDetectorEyeBlink : [NSNumber numberWithBool:[self detectEyes]],
                                                 CIDetectorSmile    : [NSNumber numberWithBool:[self detectSmile]],
                                                 CIDetectorImageOrientation : imageOrientation}];
    
    BOOL faceFeaturesNotDetected = [features count] < 1;
    if (faceFeaturesNotDetected)
    {
        if ([self detectEyes]) {
            if (_eyesDetected) {
                [self notifyEyesDidLost];
                self.eyesDetected = NO;
            }
        }
        if ([self detectSmile]) {
            if (_smileDetected) {
                [self notifySmileDidLost];
                self.smileDetected = NO;
            }
        }
    } else {
        CIFaceFeature *faceFeature = [features objectAtIndex:0];
        if ([self detectEyes]) {
            [self processEyesFeatures:faceFeature];
        }
        
        if ([self detectSmile]) {
            [self processSmileFeatures:faceFeature];
        }
    }
}

- (void)processEyesFeatures:(CIFaceFeature *)faceFeature
{
    if (faceFeature.hasLeftEyePosition && faceFeature.hasRightEyePosition) {
        
        if (!_eyesDetected) {
            [self notifyEyesDetected];
            self.eyesDetected = YES;
        }
        
        // Left eye and right eye are mirrored!
        BOOL bothEyesDidCloseSimultaneouslyEvent = !_bothEyesClosed && faceFeature.leftEyeClosed && faceFeature.rightEyeClosed;
        BOOL bothEyesDidOpenSimultaneouslyEvent = _bothEyesClosed && !faceFeature.leftEyeClosed && !faceFeature.rightEyeClosed;
        BOOL leftEyeDidCloseEvent = faceFeature.rightEyeClosed && !_leftEyeClosed;
        BOOL leftEyeDidOpenEvent = !faceFeature.rightEyeClosed && _leftEyeClosed;
        BOOL rightEyeDidCloseEvent = faceFeature.leftEyeClosed && !_rightEyeClosed;
        BOOL rightEyeDidOpenEvent = !faceFeature.leftEyeClosed && _rightEyeClosed;
        
        
        /* Properties
         @property BOOL rightEyeClosed;
         @property BOOL leftEyeClosed;
         @property BOOL bothEyesClosed;
         @property BOOL eyesDetected;
         
         should be read and change ONLY here. Do it early in order to sync state
         with calls to subscribers. F.e., when subscriber was notified with
         leftEyeDidClose - it can check
         [[UIEyeGestureDetector sharedDetector] leftEyeClosed] and get correct value.
         */
        self.bothEyesClosed = faceFeature.leftEyeClosed && faceFeature.rightEyeClosed;
        self.leftEyeClosed = faceFeature.rightEyeClosed;
        self.rightEyeClosed = faceFeature.leftEyeClosed;
        
        {
            if (bothEyesDidCloseSimultaneouslyEvent) {
                [self notifyBothEyesDidClose];
            }
            if (bothEyesDidOpenSimultaneouslyEvent) {
                [self notifyBothEyesDidOpen];
            }
        }
        
        {
            if (leftEyeDidCloseEvent
                && !bothEyesDidCloseSimultaneouslyEvent) {
                [self notifyLeftEyeDidClose];
            }
            if (leftEyeDidOpenEvent
                && !bothEyesDidOpenSimultaneouslyEvent) {
                [self notifyLeftEyeDidOpen];
            }
        }
        
        {
            if (rightEyeDidCloseEvent
                && !bothEyesDidCloseSimultaneouslyEvent) {
                [self notifyRightEyeDidClose];
            }
            if (rightEyeDidOpenEvent
                && !bothEyesDidOpenSimultaneouslyEvent) {
                [self notifyRightEyeDidOpen];
            }
        }
        
    } else {
        if (_eyesDetected) {
            [self notifyEyesDidLost];
            self.eyesDetected = NO;
        }
    }
}

- (void)processSmileFeatures:(CIFaceFeature *)faceFeature
{
    if (faceFeature.hasSmile) {
        if (!_smileDetected) {
            [self notifySmileDetected];
            self.smileDetected = YES;
        }
    } else {
        if (_smileDetected) {
            [self notifySmileDidLost];
            self.smileDetected = NO;
        }
    }
}

#pragma mark - Subscribers Notifications
- (void)notifyEyesDetected
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToEyesDetected]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] eyesDetected];
            });
        }
    }
}

- (void)notifyEyesDidLost
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToEyesLost]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] eyesLost];
            });
        }
    }
}

- (void)notifyLeftEyeDidClose
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToLeftEyeDidClose]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] leftEyeDidClose];
            });
        }
    }
}

- (void)notifyLeftEyeDidOpen
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToLeftEyeDidOpen]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] leftEyeDidOpen];
            });
        }
    }
}

- (void)notifyBothEyesDidOpen
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToBothEyesDidOpen]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] bothEyesDidOpen];
            });
        }
    }
}

- (void)notifyBothEyesDidClose
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToBothEyesDidClose]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] bothEyesDidClose];
            });
        }
    }
}

- (void)notifyRightEyeDidClose
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToRightEyeDidClose]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] rightEyeDidClose];
            });
        }
    }
}

- (void)notifyRightEyeDidOpen
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        if ([subscriberDecorator respondsToRightEyeDidOpen]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[subscriberDecorator subscriber] rightEyeDidOpen];
            });
        }
    }
}

- (void)notifySmileDetected
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([subscriberDecorator respondsToSmileDetected]) {
                [[subscriberDecorator subscriber] smileDetected];
            }
        });
    }
}

- (void)notifySmileDidLost
{
    for (UIFaceGestureSubscriberDecorator* subscriberDecorator in _subscriberDecorators) {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            if ([subscriberDecorator respondsToSmileLost]) {
                [[subscriberDecorator subscriber] smileLost];
            }
        });
    }
}

@end
