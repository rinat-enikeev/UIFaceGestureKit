//
//  UIEyeKeyboardViewViewController.m
//  UIEyeKit
//
//  Created by Rinat Enikeev on 7/26/14.
//  Copyright (c) 2014 Rinat Enikeev. All rights reserved.
//

#import "UIEyeKeyboard.h"
#import "UIEyeKeyboardView.h"
#import "UIViewController+UIFaceGestureKit.h"
#import "UIFaceGestureKitBundle.h"
#import "UIFaceGestureKitEyeGestures.h"

static const NSInteger ZERO_BUTTON_TAG = 777; // matches tag in xibs
static const NSString* SPACE_CHAR = @"SPACE";  // matches character in KeyboardCharacters.strings

@interface UIEyeKeyboard ()
@property (strong, nonatomic) UIEyeKeyboardView* currentKeyboard;
@property (strong, nonatomic) NSArray* currentKeyboardMatch;

@property (strong, nonatomic) UIEyeKeyboardView* englishCharactersKeyboard;
@property (strong, nonatomic) NSArray* englishCharactersKeyboardMatch;
@property (strong, nonatomic) NSArray* englishCharactersKeyboardShiftedMatch;

@property (strong, nonatomic) UIEyeKeyboardView* englishDigitsKeyboard;
@property (strong, nonatomic) NSArray* englishDigitsKeyboardMatch;
@property (strong, nonatomic) UIEyeKeyboardView* englishSharpKeyboard;
@property (strong, nonatomic) NSArray* englishSharpKeyboardMatch;

@property (strong, nonatomic) UIEyeKeyboardView* localeCharactersKeyboard;
@property (strong, nonatomic) NSArray* localeCharactersKeyboardMatch;
@property (strong, nonatomic) NSArray* localeCharactersKeyboardShiftedMatch;
@property (strong, nonatomic) UIEyeKeyboardView* localeDigitsKeyboard;
@property (strong, nonatomic) NSArray* localeDigitsKeyboardMatch;
@property (strong, nonatomic) UIEyeKeyboardView* localeSharpKeyboard;
@property (strong, nonatomic) NSArray* localeSharpKeyboardMatch;

@property (strong, nonatomic) UIImage* leftShiftUpImage;
@property (strong, nonatomic) UIImage* leftShiftDownImage;
@property (strong, nonatomic) UIImage* rightShiftUpImage;
@property (strong, nonatomic) UIImage* rightShiftDownImage;

@property (strong, nonatomic) UIImage* localeShiftUpImage;
@property (strong, nonatomic) UIImage* localeShiftDownImage;
@property (strong, nonatomic) UIImage* enShiftUpImage;
@property (strong, nonatomic) UIImage* enShiftDownImage;

@property (nonatomic) BOOL shifted;
@property (nonatomic) BOOL localeLang;

@property NSUInteger eyeSelectedButtonTag;

@property (nonatomic) BOOL isPresented;

@end

@implementation UIEyeKeyboard

+(BOOL)isPad
{
    return [[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad;
}

+(BOOL)isIPhone5
{
    return ( fabs( ( double )[ [ UIScreen mainScreen ] bounds ].size.height - ( double )568 ) < DBL_EPSILON );
}

#pragma mark - Singleton
static UIEyeKeyboard *sharedInstance = nil;

+ (UIEyeKeyboard *)sharedKeyboard
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

#pragma mark - Present/Dismiss
-(void)presentKeyboardAnimated:(BOOL)animated
{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    [window addSubview:self.view];
    [self setupViewsForOrientation:self.interfaceOrientation];
    if (animated) {
        [self.view setFrame:[self underScreenKeyboardFrame]];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view setFrame:[self bottomOfScreenKeyboardFrame]];
        } completion:nil];
    } else {
        [self.view setFrame:[self bottomOfScreenKeyboardFrame]];
    }
    [self.view setHidden:NO];
    self.faceInteractionEnabled = YES;
    self.isPresented = YES;
}

-(void)dismissKeyboardAnimated:(BOOL)animated
{
    [self setupViewsForOrientation:self.interfaceOrientation];
    if (animated) {
        [self.view setFrame:[self bottomOfScreenKeyboardFrame]];
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [self.view setFrame:[self underScreenKeyboardFrame]];
        } completion:^(BOOL finished) {
            [self.view setHidden:YES];
            [self.view removeFromSuperview];
        }];
    } else {
        [self.view setFrame:[self underScreenKeyboardFrame]];
        [self.view removeFromSuperview];
    }
    self.faceInteractionEnabled = NO;
    self.isPresented = NO;
}

-(CGRect)underScreenKeyboardFrame
{
    CGRect underScreenFrame = [self.view frame];
    if ([UIEyeKeyboard isPad]) {
        underScreenFrame.origin.y = 1024.0f;
    } else {
        if ([UIEyeKeyboard isIPhone5]) {
            underScreenFrame.origin.y = 568.0f;
        } else {
            underScreenFrame.origin.y = 480.0f;
            
        }
    }
    return underScreenFrame;
}

-(CGRect)bottomOfScreenKeyboardFrame
{
    CGRect bottomOfScreenRect = [self.view frame];
    if ([UIEyeKeyboard isPad]) {
        if (UIDeviceOrientationIsLandscape(self.interfaceOrientation)) {
            bottomOfScreenRect.origin.y = 416.0f;
        } else if (UIDeviceOrientationIsPortrait(self.interfaceOrientation)) {
            bottomOfScreenRect.origin.y = 760.0f;
        }
    } else {
        if ([UIEyeKeyboard isIPhone5]) {
            bottomOfScreenRect.origin.y = 352.0f;
        } else {
            bottomOfScreenRect.origin.y = 264.0f;
        }
    }
    return bottomOfScreenRect;
}

#pragma mark - Initializers
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.hightlightColor = [UIColor blueColor]; // by default
    }
    
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.hightlightColor = [UIColor blueColor]; // by default
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil;
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.hightlightColor = [UIColor blueColor]; // by default
        [self initKeyboardViews];
    }
    return self;
}

- (void)initKeyboardViews
{
    if ([UIEyeKeyboard isPad]) {
        NSArray* nib = [[UIFaceGestureKitBundle bundle] loadNibNamed:@"UIEyeKeyboardView" owner:self options:nil];
        self.englishCharactersKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:0];
        self.englishCharactersKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_EN", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.englishCharactersKeyboardShiftedMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHIFT_EN", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.englishDigitsKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:1];
        self.englishDigitsKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_DIGITS_EN", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.englishSharpKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:2];
        self.englishSharpKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHARP_EN", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        
        self.localeCharactersKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:3];
        self.localeCharactersKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.localeCharactersKeyboardShiftedMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHIFT", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.localeDigitsKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:4];
        self.localeDigitsKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_DIGITS", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.localeSharpKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:5];
        self.localeSharpKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHARP", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        
        self.leftShiftUpImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardShiftUp" ofType:@"png"]];
        self.leftShiftDownImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardShiftDown" ofType:@"png"]];
        self.rightShiftUpImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardRightShiftUp" ofType:@"png"]];
        self.rightShiftDownImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardRightShiftDown" ofType:@"png"]];
    } else {
        NSArray* nib = [[UIFaceGestureKitBundle bundle] loadNibNamed:@"UIEyeKeyboardViewIPhone" owner:self options:nil];
        self.englishCharactersKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:0];
        self.englishCharactersKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_EN_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.englishCharactersKeyboardShiftedMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHIFT_EN_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.englishDigitsKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:1];
        self.englishDigitsKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_DIGITS_EN_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.englishSharpKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:2];
        self.englishSharpKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHARP_EN_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        
        self.localeCharactersKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:3];
        self.localeCharactersKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.localeCharactersKeyboardShiftedMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHIFT_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.localeDigitsKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:4];
        self.localeDigitsKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_DIGITS_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        self.localeSharpKeyboard = (UIEyeKeyboardView*)[nib objectAtIndex:5];
        self.localeSharpKeyboardMatch = [NSLocalizedStringFromTableInBundle(@"KEYBOARD_CHARACTERS_SHARP_IPHONE", @"KeyboardCharacters", [UIFaceGestureKitBundle bundle], @"") componentsSeparatedByString:@" "];
        
        self.localeShiftUpImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardRuIPhoneShiftUp" ofType:@"png"]];
        self.localeShiftDownImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardRuIPhoneShiftDown" ofType:@"png"]];
        self.enShiftUpImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardEnIPhoneRightShiftUp" ofType:@"png"]];
        self.enShiftDownImage = [UIImage imageWithContentsOfFile:[[UIFaceGestureKitBundle bundle] pathForResource:@"KeyboardEnIPhoneShiftDown" ofType:@"png"]];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    [self setKeyboard:UIEyeKeyboardTypeCharacters language:UIEyeKeyboardLanguageLocale];

    [self addFaceGesture:[[UIFaceGestureBothEyesDidWink alloc]  initWithTarget:self action:@selector(eyeGestureTapOnButton)]];
    [self addFaceGesture:[[UIFaceGestureLeftEyeIsClosed alloc]  initWithTarget:self action:@selector(selectButtonToLeft)]];
    [self addFaceGesture:[[UIFaceGestureLeftEyeDidWink alloc]   initWithTarget:self action:@selector(selectButtonToLeft)]];
    [self addFaceGesture:[[UIFaceGestureRightEyeDidWink alloc]  initWithTarget:self action:@selector(selectButtonToRight)]];
    [self addFaceGesture:[[UIFaceGestureRightEyeIsClosed alloc] initWithTarget:self action:@selector(selectButtonToRight)]];
    
    self.eyeSelectedButtonTag = ZERO_BUTTON_TAG;
    [self highlightButton];
}

-(void)setKeyboard:(UIEyeKeyboardType)keyboardType language:(UIEyeKeyboardLanguage)language
{
    switch (keyboardType) {
        case UIEyeKeyboardTypeCharacters: {
            if (language == UIEyeKeyboardLanguageEnglish) {
                self.localeLang = NO;
                self.currentKeyboardMatch = _englishCharactersKeyboardMatch;
                self.currentKeyboard = _englishCharactersKeyboard;
            } else if (language == UIEyeKeyboardLanguageLocale) {
                self.localeLang = YES;
                self.currentKeyboardMatch = _localeCharactersKeyboardMatch;
                self.currentKeyboard = _localeCharactersKeyboard;
            } else {
                [NSException raise:@"Please provide keyboard language. " format:nil];
            }
            break;
        }
        case UIEyeKeyboardTypeDigits: {
            if (language == UIEyeKeyboardLanguageEnglish) {
                self.localeLang = NO;
                self.currentKeyboardMatch = _englishDigitsKeyboardMatch;
                self.currentKeyboard  = _englishDigitsKeyboard;
            } else if (language == UIEyeKeyboardLanguageLocale) {
                self.localeLang = YES;
                self.currentKeyboardMatch = _localeDigitsKeyboardMatch;
                self.currentKeyboard  = _localeDigitsKeyboard;
            } else {
                [NSException raise:@"Please provide keyboard language. " format:nil];
            }
            break;
        }
        case UIEyeKeyboardTypeSharp: {
            if (language == UIEyeKeyboardLanguageEnglish) {
                self.localeLang = NO;
                self.currentKeyboardMatch= _englishSharpKeyboardMatch;
                self.currentKeyboard  = _englishSharpKeyboard;
            } else if (language == UIEyeKeyboardLanguageLocale) {
                self.localeLang = YES;
                self.currentKeyboardMatch = _localeSharpKeyboardMatch;
                self.currentKeyboard = _localeSharpKeyboard;
            } else {
                [NSException raise:@"Please provide keyboard language. " format:nil];
            }
            break;
        }
        default: {
            [NSException raise:@"Please provide keyboard type. " format:nil];
            break;
        }
    }

    self.view = _currentKeyboard;
    [self setupViewsForOrientation:self.interfaceOrientation];
}

#pragma mark - Orientation
- (void)didRotate:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    [self setupViewsForOrientation:orientation];
}

-(void)setupViewsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([UIEyeKeyboard isPad]) {
        if (UIDeviceOrientationIsLandscape(toInterfaceOrientation)) {
            if ([self.view superview] != nil) {
                [self.view setFrame:CGRectMake(0, 416.0f, 1024.0f, 352.0f)];
            }
        } else if (UIDeviceOrientationIsPortrait(toInterfaceOrientation)) {
            if ([self.view superview] != nil) {
                [self.view setFrame:CGRectMake(0, 760.0f, 768.0f, 264.0f)];
            }
        }
    }
}

#pragma mark - Shift behavior
- (void)shiftUp {
    if ([UIEyeKeyboard isPad]) {
        [_currentKeyboard.rightShiftButton setImage:_rightShiftUpImage forState:UIControlStateNormal];
        [_currentKeyboard.leftShiftButton setImage:_leftShiftUpImage forState:UIControlStateNormal];
    } else {
        if (_localeLang) {
            [_currentKeyboard.leftShiftButton setImage:_localeShiftUpImage forState:UIControlStateNormal];
        } else {
            [_currentKeyboard.leftShiftButton setImage:_enShiftUpImage forState:UIControlStateNormal];
        }
    }
    
    if (_localeLang) {
        self.currentKeyboardMatch = _localeCharactersKeyboardMatch;
    } else {
        self.currentKeyboardMatch = _englishCharactersKeyboardMatch;
    }
    self.shifted = NO;
}

- (void)shiftDown {
    
    if ([UIEyeKeyboard isPad]) {
        [_currentKeyboard.rightShiftButton setImage:_rightShiftDownImage forState:UIControlStateNormal];
        [_currentKeyboard.leftShiftButton setImage:_leftShiftDownImage forState:UIControlStateNormal];
    } else {
        if (_localeLang) {
            [_currentKeyboard.leftShiftButton setImage:_localeShiftDownImage forState:UIControlStateNormal];
        } else {
            [_currentKeyboard.leftShiftButton setImage:_enShiftDownImage forState:UIControlStateNormal];
        }
    }
    
    if (_localeLang) {
        self.currentKeyboardMatch = _localeCharactersKeyboardShiftedMatch;
    } else {
        self.currentKeyboardMatch = _englishCharactersKeyboardShiftedMatch;
    }
    self.shifted = YES;
}

#pragma mark - IBActions
- (IBAction)shiftPressed:(UIButton *)sender {
    if (_shifted) {
        [self shiftUp];
    } else {
        [self shiftDown];
    }
}

- (IBAction)digitsPressed:(UIButton *)sender {
    if (_localeLang) {
        self.currentKeyboard = _localeDigitsKeyboard;
        self.currentKeyboardMatch = _localeDigitsKeyboardMatch;
    } else {
        self.currentKeyboard = _englishDigitsKeyboard;
        self.currentKeyboardMatch = _englishDigitsKeyboardMatch;
    }
    self.view = _currentKeyboard;
}

- (IBAction)backspacePressed:(UIButton *)sender {
	[_textInput deleteBackward];
	[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification
														object:_textInput];
	if ([_textInput isKindOfClass:[UITextView class]])
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:_textInput];
	else if ([_textInput isKindOfClass:[UITextField class]])
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:_textInput];
}

- (IBAction)returnPressed:(UIButton *)sender {
    
	if ([self.textInput isKindOfClass:[UITextView class]])
    {
        [self.textInput insertText:@"\n"];
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:self.textInput];
    }
	else if ([self.textInput isKindOfClass:[UITextField class]])
    {
        if ([[(UITextField *)self.textInput delegate] respondsToSelector:@selector(textFieldShouldReturn:)])
        {
            [[(UITextField *)self.textInput delegate] textFieldShouldReturn:(UITextField *)self.textInput];
        }
    }
}

- (IBAction)dismissPressed:(UIButton *)sender {
    if ([self.textInput isKindOfClass:[UITextView class]]) {
        [(UITextView *)self.textInput resignFirstResponder];
    } else if ([self.textInput isKindOfClass:[UITextField class]]) {
        [(UITextField *)self.textInput resignFirstResponder];
    }
    if ([self isPresented]) {
        [self dismissKeyboardAnimated:YES];
    }
}

- (IBAction)altLangPressed:(UIButton *)sender {
    if (_localeLang) {
        self.currentKeyboard = _englishCharactersKeyboard;
        self.currentKeyboardMatch = _englishCharactersKeyboardMatch;
        self.localeLang = NO;
    } else {
        self.currentKeyboard = _localeCharactersKeyboard;
        self.currentKeyboardMatch = _localeCharactersKeyboardMatch;
        self.localeLang = YES;
    }
    self.view = _currentKeyboard;
}

- (IBAction)abcPressed:(UIButton *)sender {
    if (_localeLang) {
        self.currentKeyboard = _localeCharactersKeyboard;
        self.currentKeyboardMatch = _localeCharactersKeyboardMatch;
    } else {
        self.currentKeyboard = _englishCharactersKeyboard;
        self.currentKeyboardMatch = _englishCharactersKeyboardMatch;
    }
    self.view = _currentKeyboard;
    
}
- (IBAction)sharpPressed:(UIButton *)sender {
    if (_localeLang) {
        self.currentKeyboard = _localeSharpKeyboard;
        self.currentKeyboardMatch = _localeSharpKeyboardMatch;
    } else {
        self.currentKeyboard = _englishSharpKeyboard;
        self.currentKeyboardMatch = _englishSharpKeyboardMatch;
    }
    self.view = _currentKeyboard;
}

- (IBAction)characterPressed:(UIButton *)sender {
    NSInteger charPosition = [self buttonTag:sender];
    NSString* character = [_currentKeyboardMatch objectAtIndex:charPosition];
    if ([SPACE_CHAR isEqualToString:character]) {
        character = @" ";
    }
    [_textInput insertText:character];
    
	if ([_textInput isKindOfClass:[UITextView class]]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextViewTextDidChangeNotification object:_textInput];
    }
	else if ([_textInput isKindOfClass:[UITextField class]]) {
		[[NSNotificationCenter defaultCenter] postNotificationName:UITextFieldTextDidChangeNotification object:_textInput];
    }
    
    if (_shifted) {
		[self shiftUp];
    }
}

-(NSInteger)buttonTag:(UIButton*)button
{
    NSInteger tag = [button tag];
    if (tag == ZERO_BUTTON_TAG) {
        tag = 0;
    }
    return tag;
}

#pragma mark - EyeControl
-(void)selectButtonToLeft
{
    if ([self faceInteractionEnabled] && [self isPresented]) {
        [self moveToPreviousSymbol];
    }
}

-(void)selectButtonToRight
{
    if ([self faceInteractionEnabled] && [self isPresented]) {
        [self moveToNextSymbol];
    }
}

-(void)incrementEyeSelectedButtonTag
{
    if (_eyeSelectedButtonTag == ZERO_BUTTON_TAG) {
        _eyeSelectedButtonTag = 1;
    } else if (_eyeSelectedButtonTag >= [_currentKeyboardMatch count] - 1) {
        _eyeSelectedButtonTag = ZERO_BUTTON_TAG;
    } else {
        _eyeSelectedButtonTag++;
    }
}

-(void)decrementEyeSelectedButtonTag
{
    if (_eyeSelectedButtonTag == ZERO_BUTTON_TAG) {
        _eyeSelectedButtonTag = [_currentKeyboardMatch count] - 1;
    } else if (_eyeSelectedButtonTag == 1) {
        _eyeSelectedButtonTag = ZERO_BUTTON_TAG;
    } else {
        _eyeSelectedButtonTag--;
    }
}

-(void)moveToPreviousSymbol
{
    [self deHighlightButton];
    [self decrementEyeSelectedButtonTag];
    [self highlightButton];
}

-(void)moveToNextSymbol
{
    [self deHighlightButton];
    [self incrementEyeSelectedButtonTag];
    [self highlightButton];
}

-(void)highlightButton {
    UIButton* button = (UIButton*)[_currentKeyboard viewWithTag:_eyeSelectedButtonTag];
    [button setHighlighted:YES];
    button.layer.borderColor = [_hightlightColor CGColor];
    button.layer.borderWidth = 2.0f;
}

-(void)deHighlightButton
{
    UIButton* button = (UIButton*)[_currentKeyboard viewWithTag:_eyeSelectedButtonTag];
    [button setHighlighted:NO];
    button.layer.borderWidth = 0.0f;
}

-(void)eyeGestureTapOnButton
{
    if ([self faceInteractionEnabled] && [self isPresented]) {
        UIButton* button = (UIButton*)[_currentKeyboard viewWithTag:_eyeSelectedButtonTag];
        UIColor* previousColor = [button backgroundColor];
        [UIView animateWithDuration:0.2 animations:^{
            [button setBackgroundColor:[UIColor colorWithRed:0 green:1.0f blue:0 alpha:0.4]];
        } completion:^(BOOL finished) {
            [button setBackgroundColor:previousColor];
        }];
        [button sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
