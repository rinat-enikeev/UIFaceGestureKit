//
//  UIFaceGestureKitBundle.m
//  UIFaceGestureKit
//
//  Created by Rinat Enikeev on 13/08/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIFaceGestureKitBundle.h"

@implementation UIFaceGestureKitBundle

+ (NSBundle *)bundle
{
    static NSBundle* bundle = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        
        NSString *libraryBundlePath = [[NSBundle mainBundle] pathForResource:@"UIFaceGestureKitBundle"
                                                                      ofType:@"bundle"];
        
        NSBundle *libraryBundle = [NSBundle bundleWithPath:libraryBundlePath];
        NSString *langID        = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString *path          = [libraryBundle pathForResource:langID ofType:@"lproj"];
        bundle              = [NSBundle bundleWithPath:path];
    });
    return bundle;
}


@end
