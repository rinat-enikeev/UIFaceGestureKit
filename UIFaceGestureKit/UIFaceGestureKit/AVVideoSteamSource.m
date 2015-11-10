//
//  AVVideoSteamSource.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 8/5/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "AVVideoSteamSource.h"
#import <UIKit/UIKit.h>
#import "AVVideoSteamSourceSettings.h"

@interface AVVideoSteamSource ()
@property (nonatomic) BOOL isUsingFrontFacingCamera;
@property (nonatomic) BOOL isRunning;
@property (nonatomic, strong) AVCaptureSession *session;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoDataOutput;
@property (nonatomic) dispatch_queue_t videoDataOutputQueue;
@property (nonatomic) NSMutableSet* subscribers;
@end

@implementation AVVideoSteamSource

#pragma mark - Singleton
static AVVideoSteamSource *sharedInstance = nil;

+ (AVVideoSteamSource *)sharedSource
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

#pragma mark - Accessors
-(NSMutableSet*)subscribers
{
    if (_subscribers == nil) {
        _subscribers = [NSMutableSet set];
    }
    return _subscribers;
}

#pragma mark - Publisher/Subscriber
-(void)addSubscriber:(NSObject<AVVideoSteamSourceSubscriber> *)subscriber
{
    @synchronized([self subscribers]) {
        [[self subscribers] addObject:subscriber];
        TRC_NRM(@"%@ subscriber added. ", NSStringFromClass([sharedInstance class]));
    }
    if (![self isRunning]) {
        [self setUp];
        self.isRunning = YES;
    }
}

-(void)removeSubscriber:(NSObject<AVVideoSteamSourceSubscriber> *)subscriber;
{
    @synchronized([self subscribers]) {
        [[self subscribers] removeObject:subscriber];
        TRC_NRM(@"%@ subscriber removed. ", NSStringFromClass([sharedInstance class]));
    }
    
    if ([[self subscribers] count] == 0) {
        [self tearDown];
        self.isRunning = NO;
    }
}

#pragma mark - SetUp and TearDown
- (void)setUp
{
	NSError *error = nil;
	
	self.session = [[AVCaptureSession alloc] init];
    [_session setSessionPreset:[[AVVideoSteamSourceSettings sharedSettings] captureSessionPreset]];

    // Select a video device, make an input
	AVCaptureDevice *device;
    AVCaptureDevicePosition desiredPosition = AVCaptureDevicePositionFront;
	
    // find the front facing camera
	for (AVCaptureDevice *d in [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo]) {
		if ([d position] == desiredPosition) {
			device = d;
            self.isUsingFrontFacingCamera = YES;
			break;
		}
	}
    
    // fall back to the default camera.
    if(device == nil)
    {
        self.isUsingFrontFacingCamera = NO;
        device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    }
    
    // get the input device
    AVCaptureDeviceInput *deviceInput = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
    
	if(!error) {
        // add the input to the session
        if ([_session canAddInput:deviceInput])
        {
            [_session addInput:deviceInput];
        } else {
            TRC_ERR(@"Failed to add device input. ");
        }
        
        // Make a video data output
        self.videoDataOutput = [[AVCaptureVideoDataOutput alloc] init];
        
        // we want BGRA, both CoreGraphics and OpenGL work well with 'BGRA' kCMPixelFormat_32BGRA
        NSDictionary *rgbOutputSettings = @{(id)kCVPixelBufferPixelFormatTypeKey : [[AVVideoSteamSourceSettings sharedSettings] pixelBufferFormat]};
        [self.videoDataOutput setVideoSettings:rgbOutputSettings];
        [self.videoDataOutput setAlwaysDiscardsLateVideoFrames:YES]; // discard if the data output queue is blocked
        
        // create a serial dispatch queue used for the sample buffer delegate
        // a serial dispatch queue must be used to guarantee that video frames will be delivered in order
        // see the header doc for setSampleBufferDelegate:queue: for more information
        self.videoDataOutputQueue = dispatch_queue_create("AVVideoSteamSourceVideoDataOutputQueue", DISPATCH_QUEUE_SERIAL);
        [self.videoDataOutput setSampleBufferDelegate:self queue:self.videoDataOutputQueue];
        
        if ( [_session canAddOutput:self.videoDataOutput] ){
            [_session addOutput:self.videoDataOutput];
        } else {
            TRC_ERR(@"Failed to add output to session. ");
        }
        
        // get the output for doing face detection.
        AVCaptureConnection* connection = [self.videoDataOutput connectionWithMediaType:AVMediaTypeVideo];
        [connection setEnabled:YES];
        
        if (![device lockForConfiguration:&error]) {
            TRC_ERR(@"Failed to lock device %@ for configuration. ", device);
        } else {
            AVCaptureDeviceFormat *format = device.activeFormat;
            CMTimeScale frameRatePerSec = [[AVVideoSteamSourceSettings sharedSettings] frameRatePerSec];
            for (AVFrameRateRange *range in format.videoSupportedFrameRateRanges) {
                
                if (range.minFrameRate <= (frameRatePerSec + DBL_EPSILON) &&
                    range.maxFrameRate >= (frameRatePerSec - DBL_EPSILON)) {
                    
                    device.activeVideoMaxFrameDuration = (CMTime){
                        .value = 1,
                        .timescale = frameRatePerSec,
                        .flags = kCMTimeFlags_Valid,
                        .epoch = 0,
                    };
                    device.activeVideoMinFrameDuration = (CMTime){
                        .value = 1,
                        .timescale = frameRatePerSec,
                        .flags = kCMTimeFlags_Valid,
                        .epoch = 0,
                    };
                    break;
                }
            }
            
            [device unlockForConfiguration];
        }
        
        [_session startRunning];
        TRC_NRM(@"Started video stream capture. ");
    } else {
        TRC_ERR(@"Error while setting up video stream source: %@", [error localizedDescription]);
	}
}

-(void)tearDown
{
    [self.session stopRunning];
    self.session = nil;
    TRC_NRM(@"Stopped video stream capture. ");
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
-(void)captureOutput:(AVCaptureOutput *)captureOutput
        didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
         fromConnection:(AVCaptureConnection *)connection
{
    // {{ 1. Prepare image
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer
                                                      options:(__bridge NSDictionary *)attachments];
	if (attachments) {
		CFRelease(attachments);
    }
    // Prepare image }}
    
    // {{ 2. Get features
	UIDeviceOrientation curDeviceOrientation = [[UIDevice currentDevice] orientation];
    NSNumber* imageOrientation = [self exifOrientation:curDeviceOrientation];
    
    for (NSObject<AVVideoSteamSourceSubscriber>* subscriber in [self subscribers])
    {
        [subscriber videoStreamSource:self
                         capturedImage:ciImage
                            inOrientation:imageOrientation];
    }
}

-(NSNumber *)exifOrientation:(UIDeviceOrientation)orientation
{
	int exifOrientation;
    /* kCGImagePropertyOrientation values
     The intended display orientation of the image. If present, this key is a CFNumber value with the same value as defined
     by the TIFF and EXIF specifications -- see enumeration of integer constants.
     The value specified where the origin (0,0) of the image is located. If not present, a value of 1 is assumed.
     
     used when calling featuresInImage: options: The value for this key is an integer NSNumber from 1..8 as found in kCGImagePropertyOrientation.
     If present, the detection will be done based on that orientation but the coordinates in the returned features will still be based on those of the image. */
    
	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (orientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (self.isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (self.isUsingFrontFacingCamera)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    return [NSNumber numberWithInt:exifOrientation];
}


@end
