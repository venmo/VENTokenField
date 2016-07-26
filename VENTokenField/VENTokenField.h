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

NS_ASSUME_NONNULL_BEGIN

@class VENTokenField;
@protocol VENTokenFieldDelegate <NSObject>
@optional
- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text;
- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index;
- (void)tokenField:(VENTokenField *)tokenField didChangeText:(nullable NSString *)text;
- (void)tokenFieldDidBeginEditing:(VENTokenField *)tokenField;
- (void)tokenFieldWillBeginToEdit:(VENTokenField *)tokenField;
- (void)tokenFieldDidEndEditing:(VENTokenField *)tokenField;
- (void)tokenField:(VENTokenField *)tokenField didChangeContentHeight:(CGFloat)height;
@end

@protocol VENTokenFieldDataSource <NSObject>
@optional
- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField;
- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField;
- (UIColor *)tokenField:(VENTokenField *)tokenField colorSchemeForTokenAtIndex:(NSUInteger)index;
- (Class)tokenViewForTokenField:(VENTokenField *)tokenField;
@end


@interface VENTokenField : UIView

@property (weak, nonatomic) id<VENTokenFieldDelegate> delegate;
@property (weak, nonatomic) id<VENTokenFieldDataSource> dataSource;

- (void)reloadData;
- (void)collapse;
- (nullable NSString *)inputText;


/**-----------------------------------------------------------------------------
 * @name Customization
 * -----------------------------------------------------------------------------
 */

@property (assign, nonatomic) CGFloat maxHeight;
@property (assign, nonatomic) CGFloat verticalInset;
@property (assign, nonatomic) CGFloat horizontalInset;
@property (assign, nonatomic) CGFloat tokenPadding;
@property (assign, nonatomic) CGFloat minInputWidth;

@property (assign, nonatomic) UIKeyboardType inputTextFieldKeyboardType;
@property (assign, nonatomic) UIKeyboardAppearance inputTextFieldKeyboardAppearance;

@property (assign, nonatomic) UITextAutocorrectionType autocorrectionType;
@property (assign, nonatomic) UITextAutocapitalizationType autocapitalizationType;
@property (assign, nonatomic, nullable) UIView *inputTextFieldAccessoryView;
@property (strong, nonatomic) UIColor *toLabelTextColor;
@property (strong, nonatomic, nullable) NSString *toLabelText;
@property (strong, nonatomic) UIColor *inputTextFieldTextColor;

@property (strong, nonatomic) UILabel *toLabel;

@property (strong, nonatomic, nullable) NSArray *delimiters;
@property (copy, nonatomic, nullable) NSString *placeholderText;
@property (copy, nonatomic, nullable) NSString *inputTextFieldAccessibilityLabel;

- (void)setColorScheme:(UIColor *)color;

@end

NS_ASSUME_NONNULL_END
