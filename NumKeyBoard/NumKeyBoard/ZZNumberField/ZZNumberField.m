//
//  ZZNumberField.m
//  NumKeyBoard
//
//  Created by zm on 2016/11/21.
//  Copyright © 2016年 zmMac. All rights reserved.
//

#import "ZZNumberField.h"
#define kButtonWidth  ([UIScreen mainScreen].bounds.size.width - 4*kInter)/3
#define kInter 1

static const NSInteger kButtonValueAffim = 10;
static const NSInteger kButtonValueDelete = 11;

static const NSInteger kButtonValues[] = {
    1, 2, 3,
    4, 5, 6,
    7, 8, 9,
    kButtonValueAffim, 0, kButtonValueDelete
};

static NSString * const kButtonLabels[] = {
    @"1", @"2", @"3",
    @"4", @"5", @"6",
    @"7", @"8", @"9",
    @"确定", @"0", @"NumberPadDelete",
};

static NSString * const kButtonAccessibilityLabels[] = {
    @"1", @"2", @"3",
    @"4", @"5", @"6",
    @"7", @"8", @"9",
    @"确定", @"0", @"Delete",
};

static const CGRect kInputViewFrame = { 0, 0, 320, 216 };

/*
 320px = 1px + 105px + 1px + 106px + 1px + 105px + 1px
 320px = 1px + 105px + 1px + 106px + 1px + 52px + 1px + 52px + 1px
 216px = 1px + 53px + 1px + 53px + 1px + 53px + 1px + 53px + 1px
 */

@interface ZZNumberField ()

- (void)updateLabel;
- (void)doChangeSign;
- (void)doInsertDecimalPoint;
- (void)doDelete;
- (void)doClear;
- (void)doInsertZero;
- (void)doInsertDigit:(NSUInteger)digit;
@end

@interface ZZNumericInputView()

@property (nonatomic, strong) NSMutableArray * buttons;

@end

@implementation ZZNumericInputView

+ (ZZNumericInputView *)sharedInputView
{
    static ZZNumericInputView *view = nil;
    
    if (view == nil) {
        view = [[ZZNumericInputView alloc] initWithFrame:kInputViewFrame];
    }
    return view;
}

- (void)layoutSubviews{
    NSLog(@"%f",[UIScreen mainScreen].bounds.size.width);
    
    [self updateButtonFrame];
    
}
- (void)updateButtonFrame{
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton * btn = self.buttons[i*3+j];
            btn.frame = CGRectMake(1 + j*(kInter + kButtonWidth), 1 + i*(kInter + 53), kButtonWidth, 53);
            
        }
    }
}

- (void)createButton{
    for (int i = 0; i < 4; i++) {
        for (int j = 0; j < 3; j++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            [self.buttons addObject:btn];
            NSString *title = kButtonLabels[i*3 + j];
            btn.tag = kButtonValues[i*3 + j];
            btn.frame = CGRectMake(1 + j*(kInter + kButtonWidth), 1 + i*(kInter + 53), kButtonWidth, 53);
            [self addSubview:btn];
            
            if ([title length] == 1 || [title isEqualToString:@"确定"]) {
                UIColor *shadowColor = [UIColor colorWithRed:0.357 green:0.373 blue:0.400 alpha:1.000];
                btn.titleLabel.font = [UIFont boldSystemFontOfSize:30];
                btn.titleLabel.shadowOffset = CGSizeMake(0, -1);
                btn.reversesTitleShadowWhenHighlighted = YES;
                [btn setTitle:title forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [btn setTitleShadowColor:shadowColor forState:UIControlStateNormal];
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateHighlighted];
                [btn setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
            } else {
                NSString *titleUp = [title stringByAppendingString:@"Up"];
                [btn setImage:[UIImage imageNamed:titleUp] forState:UIControlStateNormal];
                NSString *titleDown = [title stringByAppendingString:@"Down"];
                [btn setImage:[UIImage imageNamed:titleDown] forState:UIControlStateHighlighted];
            }
            NSString *label = kButtonAccessibilityLabels[i*3 + j];
            [btn setAccessibilityLabel:label];
            [btn
             setBackgroundImage:[UIImage imageNamed:@"NumberPadButtonUp"]
             forState:UIControlStateNormal];
            [btn
             setBackgroundImage:[UIImage imageNamed:@"NumberPadButtonDown"]
             forState:UIControlStateHighlighted];
            [btn
             addTarget:[UIDevice currentDevice] action:@selector(playInputClick)
             forControlEvents:UIControlEventTouchDown];
            [btn
             addTarget:nil action:@selector(numericInputViewButtonTouchUpInside:)
             forControlEvents:UIControlEventTouchUpInside];
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor colorWithRed:0.25f green:0.25f blue:0.25f alpha:1];
        self.buttons = @[].mutableCopy;
        [self createButton];
    }
    return self;
}

- (void)becomeActiveField:(ZZNumberField *)field
{
    activeField = field;
}

- (void)resignActiveField:(ZZNumberField *)field
{
    if (activeField == field) activeField = nil;
}

- (void)numericInputViewButtonTouchUpInside:(id)sender
{
    switch ([sender tag]) {
        case kButtonValueAffim:
            [activeField doChangeSign];
            break;
        case kButtonValueDelete:
            [activeField doDelete];
            break;
        case 0:
            [activeField doInsertZero];
            break;
        default:
            [activeField doInsertDigit:[sender tag]];
            break;
    }
    [activeField updateLabel];
    [activeField sendActionsForControlEvents:UIControlEventValueChanged];
}

// MARK: UIInputViewAudioFeedback

- (BOOL)enableInputClicksWhenVisible
{
    return YES;
}

// MARK: UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

@end


@implementation ZZNumberField
- (void)initSubviews
{
    self.inputView = [ZZNumericInputView sharedInputView];
    if (self.delegate == nil) {
        self.delegate = [ZZNumericInputView sharedInputView];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        
        [self initSubviews];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self initSubviews];
    }
    return self;
}

- (void)dealloc
{
    [[ZZNumericInputView sharedInputView] resignActiveField:self];
}

- (void)setText:(NSString *)text
{
    if ([text length]) {
        [self setNumberValue:[NSNumber numberWithDouble:[text doubleValue]]];
    } else {
        [self setNumberValue:nil];
    }
}

- (NSNumber *)numberValue
{
    if (integerDigits == nil) return nil;
    NSMutableString *digits = [NSMutableString string];
    if (isNegative) {
        [digits appendString:@"-"];
    }
    [digits appendString:integerDigits];
    if (fractionalDigits) {
        [digits appendString:@"."];
        [digits appendString:fractionalDigits];
    }
    return [NSNumber numberWithDouble:[digits doubleValue]];
}

- (void)setNumberValue:(NSNumber *)numberValue
{
    if (numberValue == nil) {
        isNegative = NO;
        integerDigits = nil;
        fractionalDigits = nil;
        [self updateLabel];
        return;
    }
    NSString *digits = [NSString stringWithFormat:@"%.6f", [numberValue doubleValue]];
    NSCharacterSet *digitSet = [NSCharacterSet decimalDigitCharacterSet];
    NSScanner *scanner = [NSScanner scannerWithString:digits];
    isNegative = [scanner scanString:@"-" intoString:nil];
    NSString *part;
    if ([scanner scanCharactersFromSet:digitSet intoString:&part]) {
        integerDigits = [part mutableCopy];
    } else {
        integerDigits = nil;
    }
    if ([scanner scanString:@"." intoString:nil] &&
        [scanner scanCharactersFromSet:digitSet intoString:&part]) {
        // Don't copy any trailing zeroes.
        NSUInteger len = [part length];
        while (len > 0 && [part characterAtIndex:(len - 1)] == '0') {
            len -= 1;
        }
        if (len > 0) {
            fractionalDigits = [[part substringToIndex:len] mutableCopy];
        } else {
            fractionalDigits = nil;
        }
    } else {
        fractionalDigits = nil;
    }
    NSAssert1([scanner isAtEnd], @"Leftover Digits! '%@'", digits);
    [self updateLabel];
}

// MARK: Private Methods

- (void)updateLabel
{
    NSUInteger len = 1 + [integerDigits length] + 1 + [fractionalDigits length];
    NSMutableString *displayString = [NSMutableString stringWithCapacity:len];
    if (integerDigits != nil) {
        if (isNegative) {
            [displayString appendString:@"-"];
        }
        if ([integerDigits length] == 0) {
            [displayString appendString:@"0"];
        } else {
            [displayString appendString:integerDigits];
        }
        if (fractionalDigits) {
            [displayString appendString:[[NSLocale currentLocale]
                                         objectForKey:NSLocaleDecimalSeparator]];
            [displayString appendString:fractionalDigits];
        }
    }
    [super setText:displayString];
}

- (void)doChangeSign
{
    [self affirmAction];
}

- (void)doInsertDecimalPoint
{
    [self affirmAction];
}

- (void)affirmAction{
    if (_numDelegate) {
        [_numDelegate didClickedAffirm:self];
    }
}



- (void)doDelete
{
    if (fractionalDigits) {
        if ([fractionalDigits length] > 0) {
            NSRange range = NSMakeRange([fractionalDigits length] - 1, 1);
            [fractionalDigits deleteCharactersInRange:range];
        } else {
            fractionalDigits = nil;
        }
    } else {
        if ([integerDigits length] > 1) {
            NSRange range = NSMakeRange([integerDigits length] - 1, 1);
            [integerDigits deleteCharactersInRange:range];
        } else {
            integerDigits = nil;
        }
    }
}

- (void)doClear
{
    isNegative = NO;
    integerDigits = nil;
    fractionalDigits = nil;
}

- (void)doInsertZero
{
    if (fractionalDigits) {
        [fractionalDigits appendFormat:@"0"];
    } else {
        if (integerDigits) {
            [integerDigits appendFormat:@"0"];
        } else {
            integerDigits = [NSMutableString stringWithFormat:@"0"];
        }
    }
}

- (void)doInsertDigit:(NSUInteger)digitValue
{
    if (fractionalDigits) {
        [fractionalDigits appendFormat:@"%lu", (unsigned long)digitValue];
    } else {
        if (integerDigits) {
            [integerDigits appendFormat:@"%lu", (unsigned long)digitValue];
        } else {
            integerDigits = [NSMutableString stringWithFormat:@"%lu", (unsigned long)digitValue];
        }
    }
}

// MARK: UIResponder

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    // Don't allow actions that we cannot support properly.
    if (action == @selector(selectAll:) || action == @selector(copy:)) {
        return [super canPerformAction:action withSender:sender];
    } else {
        return NO;
    }
}

- (BOOL)becomeFirstResponder
{
    if ([super becomeFirstResponder]) {
        [[ZZNumericInputView sharedInputView] becomeActiveField:self];
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)resignFirstResponder
{
    if ([super resignFirstResponder]) {
        [[ZZNumericInputView sharedInputView] resignActiveField:self];
        return YES;
    } else {
        return NO;
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
