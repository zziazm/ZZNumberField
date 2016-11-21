//
//  ZZNumberField.h
//  NumKeyBoard
//
//  Created by zm on 2016/11/21.
//  Copyright © 2016年 zmMac. All rights reserved.
//

#import <UIKit/UIKit.h>
@class ZZNumberField;

@protocol ZZNumberFieldDelegate <NSObject>

@optional
- (void)didClickedAffirm:(ZZNumberField *)field;


@end


@interface ZZNumberField : UITextField
{
    BOOL isNegative;
    NSMutableString *integerDigits;
    NSMutableString *fractionalDigits;
}
@property (nonatomic, strong, readwrite) NSNumber *numberValue;
@property (nonatomic, weak) id <ZZNumberFieldDelegate>numDelegate;

@end

@interface ZZNumericInputView : UIView <UIInputViewAudioFeedback, UITextFieldDelegate>

{
    __unsafe_unretained ZZNumberField *activeField;
}
+ (ZZNumericInputView *)sharedInputView;

@end
