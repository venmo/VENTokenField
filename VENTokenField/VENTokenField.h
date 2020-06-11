// VENTokenField.h
//
// Copyright (c) 2014 Venmo
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <UIKit/UIKit.h>
#import "VENBackspaceTextField.h"
#import "VENToken.h"

NS_ASSUME_NONNULL_BEGIN

@class VENTokenField;
@protocol VENTokenFieldDelegate <NSObject>
@optional
- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text;
- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index;
- (void)tokenField:(VENTokenField *)tokenField didChangeText:(nullable NSString *)text;
- (void)tokenFieldDidBeginEditing:(VENTokenField *)tokenField;
- (void)tokenField:(VENTokenField *)tokenField didChangeContentHeight:(CGFloat)height;
- (void)tokenField:(VENTokenField *)tokenField didTapTokenAtIndex:(NSUInteger)index;
- (void)tokenFieldDidTapCollapsed:(VENTokenField *)tokenField;
- (BOOL)tokenField:(VENTokenField *)tokenField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
- (void)tokenField:(VENTokenField *)tokenField didCreateToken:(UIView *)token;
@end

@protocol VENTokenFieldDataSource <NSObject>
@optional
- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField;
- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField fittingWidth:(CGFloat)width;
- (UIColor *)tokenField:(VENTokenField *)tokenField colorSchemeForTokenAtIndex:(NSUInteger)index;
- (Class)subclassForTokensInTokenField:(VENTokenField *)tokenField;
@end


@interface VENTokenField : UIView

@property (weak, nonatomic) id<VENTokenFieldDelegate> delegate;
@property (weak, nonatomic) id<VENTokenFieldDataSource> dataSource;
@property (strong, nonatomic) VENBackspaceTextField *inputTextField;
@property (strong, nonatomic) UIScrollView *scrollView;
@property (readonly, strong, nonatomic) NSMutableArray *tokens;

- (void)reloadData;
- (void)collapse;
- (void)expand;
- (void)unhighlightAllTokensSettingCursorVisibility:(BOOL)setCursorVisibility;
- (nullable NSString *)inputText;
- (BOOL)isCollapsed;
- (void)didTapToken:(UIView<VENTokenObject> *)token;

/**-----------------------------------------------------------------------------
 * @name Customization
 * -----------------------------------------------------------------------------
 */

@property (assign, nonatomic) CGFloat maxHeight;
@property (assign, nonatomic) CGFloat verticalInset;
@property (assign, nonatomic) CGFloat horizontalInset;
@property (assign, nonatomic) CGFloat tokenPadding;
@property (assign, nonatomic) CGFloat minInputWidth;
@property (assign, nonatomic) CGFloat toLabelTrailingPadding;
@property (assign, nonatomic) CGFloat toLabelLeadingPadding;

@property (assign, nonatomic) UIKeyboardType inputTextFieldKeyboardType;
@property (assign, nonatomic) UIKeyboardAppearance inputTextFieldKeyboardAppearance;

@property (assign, nonatomic) UITextAutocorrectionType autocorrectionType;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic, nullable) UIView *inputTextFieldAccessoryView;
@property (strong, nonatomic) UIColor *toLabelTextColor;
@property (strong, nonatomic) NSString *toLabelText;
@property (strong, nonatomic) UIFont *inputTextFieldFont;
@property (strong, nonatomic) UIColor *inputTextFieldTextColor;

@property (strong, nonatomic) UILabel *toLabel;
@property (strong, nonatomic) UIFont *collapsedFont;
@property (copy, nonatomic, nullable) NSString *placeholderText;
@property (copy, nonatomic, nullable) NSString *inputTextFieldAccessibilityLabel;

@end

NS_ASSUME_NONNULL_END
