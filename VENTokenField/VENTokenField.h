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

@class VENTokenField;
@protocol VENTokenFieldDelegate <NSObject>
@optional
- (void)tokenField:(VENTokenField *)tokenField didEnterText:(NSString *)text;
- (void)tokenField:(VENTokenField *)tokenField didSelectSuggestion:(NSString *)suggestion forPartialText:(NSString *)text atIndex:(NSInteger) index;
- (void)tokenField:(VENTokenField *)tokenField didDeleteTokenAtIndex:(NSUInteger)index;
- (void)tokenField:(VENTokenField *)tokenField didChangeText:(NSString *)text;
- (void)tokenFieldDidBeginEditing:(VENTokenField *)tokenField;
@end

@protocol VENTokenFieldDataSource <NSObject>
@optional
- (NSString *)tokenField:(VENTokenField *)tokenField titleForTokenAtIndex:(NSUInteger)index;
- (NSUInteger)numberOfTokensInTokenField:(VENTokenField *)tokenField;
- (NSString *)tokenFieldCollapsedText:(VENTokenField *)tokenField;
@end

@protocol VENTokenSuggestionDataSource <NSObject>
@optional
- (BOOL)tokenFieldShouldPresentSuggestions:(VENTokenField *)tokenField;
- (NSInteger)tokenField:(VENTokenField *)tokenField numberOfSuggestionsForPartialText:(NSString *)text;
- (NSString *)tokenField:(VENTokenField *)tokenField suggestionTitleForPartialText:(NSString *)text atIndex:(NSInteger)index;
@end


@interface VENTokenField : UIView

@property (weak, nonatomic) id<VENTokenFieldDelegate> delegate;
@property (weak, nonatomic) id<VENTokenFieldDataSource> dataSource;
@property (weak, nonatomic) id<VENTokenSuggestionDataSource> suggestionDataSource;

- (void)reloadData;
- (void)collapse;
- (NSString *)inputText;


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
@property (strong, nonatomic) UIColor *toLabelTextColor;
@property (strong, nonatomic) NSString *toLabelText;
@property (strong, nonatomic) UIColor *inputTextFieldTextColor;

@property (strong, nonatomic) UILabel *toLabel;

@property (copy, nonatomic) NSString *placeholderText;

- (void)setColorScheme:(UIColor *)color;

@end

