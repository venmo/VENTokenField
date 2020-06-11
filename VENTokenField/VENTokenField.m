// VENTokenField.m
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

#import "VENTokenField.h"

#import "VENToken.h"

static const CGFloat VENTokenFieldDefaultVerticalInset      = 7.0;
static const CGFloat VENTokenFieldDefaultHorizontalInset    = 15.0;
static const CGFloat VENTokenFieldDefaultToLabelPadding     = 5.0;
static const CGFloat VENTokenFieldDefaultTokenPadding       = 2.0;
static const CGFloat VENTokenFieldDefaultMinInputWidth      = 80.0;
static const CGFloat VENTokenFieldDefaultMaxHeight          = 150.0;


@interface VENTokenField () <VENBackspaceTextFieldDelegate>

@property (readwrite, strong, nonatomic) NSMutableArray *tokens;
@property (assign, nonatomic) CGFloat originalHeight;
@property (strong, nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (strong, nonatomic) VENBackspaceTextField *invisibleTextField;
@property (strong, nonatomic) UILabel *collapsedLabel;

@end


@implementation VENTokenField

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setUpInit];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setUpInit];
}

- (BOOL)isFirstResponder
{
    return [self.inputTextField isFirstResponder] || [self.invisibleTextField isFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    [self layoutTokensAndInputWithFrameAdjustment:YES];
    [self inputTextFieldBecomeFirstResponder];
    return YES;
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.inputTextField resignFirstResponder] || [self.invisibleTextField resignFirstResponder];
}

- (void)setUpInit
{
    // Set up default values.
    _autocorrectionType = UITextAutocorrectionTypeNo;
    _autocapitalizationType = UITextAutocapitalizationTypeSentences;
    self.maxHeight = VENTokenFieldDefaultMaxHeight;
    self.verticalInset = VENTokenFieldDefaultVerticalInset;
    self.horizontalInset = VENTokenFieldDefaultHorizontalInset;
    self.tokenPadding = VENTokenFieldDefaultTokenPadding;
    self.minInputWidth = VENTokenFieldDefaultMinInputWidth;
    self.toLabelTrailingPadding = VENTokenFieldDefaultToLabelPadding;
    self.toLabelLeadingPadding = VENTokenFieldDefaultToLabelPadding;
    self.toLabelTextColor = [UIColor colorWithRed:112/255.0f green:124/255.0f blue:124/255.0f alpha:1.0f];
    self.inputTextFieldTextColor = [UIColor colorWithRed:38/255.0f green:39/255.0f blue:41/255.0f alpha:1.0f];

    // Accessing bare value to avoid kicking off a premature layout run.
    _toLabelText = NSLocalizedString(@"To:", nil);

    [self layoutIfNeeded];
    self.originalHeight = CGRectGetHeight(self.frame);

    // Add invisible text field to handle backspace when we don't have a real first responder.
    [self layoutInvisibleTextField];

    [self layoutScrollView];
    [self reloadData];
}

- (void)collapse
{
    if ([self isCollapsed]) {
        return;
    }

    CGFloat oldHeight = self.frame.size.height;
    [self layoutCollapsedLabel];
    if (oldHeight != self.frame.size.height && [self.delegate respondsToSelector:@selector(tokenField:didChangeContentHeight:)]) {
        [self.delegate tokenField:self didChangeContentHeight:self.frame.size.height];
    }
}

- (void)expand
{
    [self layoutTokensAndInputWithFrameAdjustment:YES];
}

- (void)reloadData
{
    if ([self isCollapsed]) {
        return;
    }

    [self layoutTokensAndInputWithFrameAdjustment:YES];
}

- (void)setPlaceholderText:(NSString *)placeholderText
{
    _placeholderText = placeholderText;
    self.inputTextField.placeholder = _placeholderText;
}

-(void)setInputTextFieldAccessibilityLabel:(NSString *)inputTextFieldAccessibilityLabel {
    _inputTextFieldAccessibilityLabel = inputTextFieldAccessibilityLabel;
    self.inputTextField.accessibilityLabel = _inputTextFieldAccessibilityLabel;
}

- (void)setInputTextFieldFont:(UIFont *)inputTextFieldFont
{
    _inputTextFieldFont = inputTextFieldFont;
    self.inputTextField.font = inputTextFieldFont;
}

- (void)setInputTextFieldTextColor:(UIColor *)inputTextFieldTextColor
{
    _inputTextFieldTextColor = inputTextFieldTextColor;
    self.inputTextField.textColor = _inputTextFieldTextColor;
}

- (void)setToLabelTextColor:(UIColor *)toLabelTextColor
{
    _toLabelTextColor = toLabelTextColor;
    self.toLabel.textColor = _toLabelTextColor;
}

- (void)setToLabelText:(NSString *)toLabelText
{
    _toLabelText = toLabelText;
    [self reloadData];
}

- (void)setInputTextFieldAccessoryView:(UIView *)inputTextFieldAccessoryView
{
    _inputTextFieldAccessoryView = inputTextFieldAccessoryView;
    self.inputTextField.inputAccessoryView = _inputTextFieldAccessoryView;
}

- (NSString *)inputText
{
    return self.inputTextField.text;
}

- (void)setHeight:(CGFloat)newHeight
{
    CGRect newFrame = self.frame;
    newFrame.size.height = newHeight;
    self.frame = newFrame;
}

#pragma mark - View Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) - self.horizontalInset * 2, CGRectGetHeight(self.frame) - self.verticalInset * 2);
    self.scrollView.contentInset = UIEdgeInsetsMake(self.verticalInset,
                                                    self.horizontalInset,
                                                    self.verticalInset,
                                                    self.horizontalInset);

    if ([self isCollapsed]) {
        [self layoutCollapsedLabel];
    } else {
        [self layoutTokensAndInputWithFrameAdjustment:NO];
    }
}

- (void)layoutCollapsedLabel
{
    [self.collapsedLabel removeFromSuperview];
    self.scrollView.hidden = YES;

    CGFloat currentX = 0;
    [self layoutToLabelInView:self origin:CGPointMake(self.horizontalInset, self.verticalInset) currentX:&currentX];
    [self layoutCollapsedLabelWithCurrentX:&currentX];

    [self setHeight:CGRectGetMaxY(self.collapsedLabel.frame) + self.verticalInset];

    if (!self.tapGestureRecognizer) {
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
        [self addGestureRecognizer:self.tapGestureRecognizer];
    }
}

- (void)layoutTokensAndInputWithFrameAdjustment:(BOOL)shouldAdjustFrame
{
    [self.collapsedLabel removeFromSuperview];
    BOOL inputFieldShouldBecomeFirstResponder = self.inputTextField.isFirstResponder;
    for (UIView *subview in self.scrollView.subviews) {
        if (subview != self.inputTextField) {
            [subview removeFromSuperview];
        }
    }
    self.scrollView.hidden = NO;
    if (self.tapGestureRecognizer) {
        [self removeGestureRecognizer:self.tapGestureRecognizer];
        self.tapGestureRecognizer = nil;
    }

    if (inputFieldShouldBecomeFirstResponder && [self.delegate respondsToSelector:@selector(tokenField:didEnterText:)]) {
        if ([self.inputTextField.text length]) {
            NSString *text = self.inputTextField.text;
            self.inputTextField.text = @"";
            [self.delegate tokenField:self didEnterText:text];
        }

        [self updateLastTokenSeperator];
    }

    self.tokens = [NSMutableArray array];

    CGFloat currentX = 0;
    CGFloat currentY = 0;

    [self layoutToLabelInView:self.scrollView origin:CGPointZero currentX:&currentX];
    [self layoutTokensWithCurrentX:&currentX currentY:&currentY];
    [self layoutInputTextFieldWithCurrentX:&currentX currentY:&currentY clearInput:shouldAdjustFrame];

    if (shouldAdjustFrame) {
        [self adjustHeightForCurrentY:currentY];
    }

    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, currentY + [self heightForToken])];

    [self updateInputTextField];

    if (inputFieldShouldBecomeFirstResponder) {
        [self inputTextFieldBecomeFirstResponder];
    } else {
        [self focusInputTextField];
    }
}

- (BOOL)isCollapsed
{
    return self.collapsedLabel.superview != nil;
}

- (void)layoutScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
    self.scrollView.scrollsToTop = NO;
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.frame) - self.horizontalInset * 2, CGRectGetHeight(self.frame) - self.verticalInset * 2);
    self.scrollView.contentInset = UIEdgeInsetsMake(self.verticalInset,
                                                    self.horizontalInset,
                                                    self.verticalInset,
                                                    self.horizontalInset);
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

    [self addSubview:self.scrollView];
}

- (void)layoutInputTextFieldWithCurrentX:(CGFloat *)currentX currentY:(CGFloat *)currentY clearInput:(BOOL)clearInput
{
    *currentX += 2;
    CGFloat inputTextFieldWidth = self.scrollView.contentSize.width - *currentX;
    if (inputTextFieldWidth < self.minInputWidth) {
        inputTextFieldWidth = self.scrollView.contentSize.width;
        *currentY += [self heightForToken];
        *currentX = 2;
    }

    VENBackspaceTextField *inputTextField = self.inputTextField;
    if (clearInput) {
        inputTextField.text = @"";
    }

    // 1.0 extra y pixel makes the baseline of the input field align with the baseline of the labels
    inputTextField.frame = CGRectMake(*currentX, *currentY + 1, inputTextFieldWidth, [self heightForToken] - 1);
    [self.scrollView addSubview:inputTextField];
}

- (void)layoutCollapsedLabelWithCurrentX:(CGFloat *)currentX
{
    *currentX += self.horizontalInset + 2;
    CGRect frame = CGRectMake(*currentX, CGRectGetMinY(self.toLabel.frame), self.frame.size.width - *currentX - self.horizontalInset, self.toLabel.frame.size.height);
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    if (self.collapsedFont) {
        label.font = self.collapsedFont;
    } else {
        label.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
    }
    label.text = [self collapsedTextWithSize:frame.size];
    label.textColor = _inputTextFieldTextColor;

    [self addSubview:label];
    self.collapsedLabel = label;
}

- (void)layoutToLabelInView:(UIView *)view origin:(CGPoint)origin currentX:(CGFloat *)currentX
{
    [self.toLabel removeFromSuperview];
    self.toLabel = [self toLabel];

    CGRect newFrame = self.toLabel.frame;
    newFrame.origin = CGPointMake(origin.x + self.toLabelLeadingPadding, origin.y);

    [self.toLabel sizeToFit];
    newFrame.size.width = CGRectGetWidth(self.toLabel.frame);

    self.toLabel.frame = newFrame;

    [view addSubview:self.toLabel];

    // we directly set this to toLabelPadding instead of taking the toLabel width into account because
    // we want to have equal horizontal paddings across the toLabels of all VENTokenFields
    //*currentX += self.toLabel.hidden ? CGRectGetMinX(self.toLabel.frame) : CGRectGetMaxX(self.toLabel.frame) + self.toLabelPadding;
    *currentX += self.toLabelTrailingPadding;
}

- (void)layoutTokensWithCurrentX:(CGFloat *)currentX currentY:(CGFloat *)currentY
{
    NSUInteger numberOfTokens = [self numberOfTokens];
    for (NSUInteger i = 0; i < numberOfTokens; i++) {
        NSString *title = [self titleForTokenAtIndex:i];
        VENToken *token = [[[self subclassForTokens] alloc] init];

        if ([self.delegate respondsToSelector:@selector(tokenField:didCreateToken:)]) {
            [self.delegate tokenField:self didCreateToken:token];
        }

        // This ensures that we reset the height of the class passed in if necessary
        token.frame = CGRectMake(0, 0, 0, [self heightForToken]);

        __weak UIView<VENTokenObject> *weakToken = token;
        __weak VENTokenField *weakSelf = self;
        token.didTapTokenBlock = ^{
            [weakSelf didTapToken:weakToken];
        };

        BOOL showSeparator = (i < numberOfTokens - 1) || [self.inputTextField isFirstResponder];
        [token setTitleText:title showSeparator:showSeparator];

        [self.tokens addObject:token];

        // we need this adjustment to horizontally align the tokens with the toLabel
        if (i == 0) {
            CGFloat toLabelMidY = self.toLabel.frame.origin.y + self.toLabel.frame.size.height/2;
            *currentY = toLabelMidY - token.frame.size.height/2;
        }

        if (*currentX + token.frame.size.width <= self.scrollView.contentSize.width) { // token fits in current line
            token.frame = CGRectMake(*currentX, *currentY, ceil(token.frame.size.width), token.frame.size.height);
        } else {
            *currentY += token.frame.size.height;
            *currentX = 0;
            CGFloat tokenWidth = token.frame.size.width;
            if (tokenWidth > self.scrollView.contentSize.width) { // token is wider than max width
                tokenWidth = self.scrollView.contentSize.width;
            }
            token.frame = CGRectMake(*currentX, *currentY, ceil(tokenWidth), token.frame.size.height);
        }
        *currentX += token.frame.size.width + self.tokenPadding;
        [self.scrollView addSubview:token];
    }
}


#pragma mark - Private

- (CGFloat)heightForToken
{
    return 24;
}

- (void)layoutInvisibleTextField
{
    self.invisibleTextField = [[VENBackspaceTextField alloc] initWithFrame:CGRectZero];
    [self.invisibleTextField setAutocorrectionType:self.autocorrectionType];
    [self.invisibleTextField setAutocapitalizationType:self.autocapitalizationType];
    self.invisibleTextField.backspaceDelegate = self;
    self.invisibleTextField.delegate = self;
    self.invisibleTextField.onlyBackspaceAllowed = YES;
    [self addSubview:self.invisibleTextField];
}

- (void)inputTextFieldBecomeFirstResponder
{
    if (self.inputTextField.isFirstResponder) {
        return;
    }

    [self.inputTextField becomeFirstResponder];
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidBeginEditing:)]) {
        [self.delegate tokenFieldDidBeginEditing:self];
    }
}

- (UILabel *)toLabel
{
    if (!_toLabel) {
        _toLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _toLabel.textColor = self.toLabelTextColor;
        _toLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
        CGRect newFrame = _toLabel.frame;
        newFrame.origin.x = 0;
        _toLabel.frame = newFrame;
        [_toLabel sizeToFit];

        newFrame = _toLabel.frame;
        newFrame.size.height = [self heightForToken];
        _toLabel.frame = newFrame;
    }
    if (![_toLabel.text isEqualToString:_toLabelText]) {
        _toLabel.text = _toLabelText;
    }
    return _toLabel;
}

- (void)adjustHeightForCurrentY:(CGFloat)currentY
{
    CGFloat oldHeight = self.frame.size.height;
    CGFloat height;
    if (currentY + [self heightForToken] > CGRectGetHeight(self.frame)) { // needs to grow
        if (currentY + [self heightForToken] <= self.maxHeight) {
            height = currentY + [self heightForToken] + self.verticalInset * 2;
        } else {
            height = self.maxHeight;
        }
    } else { // needs to shrink
        if (currentY + [self heightForToken] > self.originalHeight) {
            height = currentY + [self heightForToken] + self.verticalInset * 2;
        } else {
            height = self.originalHeight;
        }
    }
    if (oldHeight != height) {
        [self setHeight:height];
        if ([self.delegate respondsToSelector:@selector(tokenField:didChangeContentHeight:)]) {
            [self.delegate tokenField:self didChangeContentHeight:height];
        }
    }
}

- (VENBackspaceTextField *)inputTextField
{
    if (!_inputTextField) {
        _inputTextField = [[VENBackspaceTextField alloc] init];
        [_inputTextField setKeyboardType:self.inputTextFieldKeyboardType];
        _inputTextField.textColor = self.inputTextFieldTextColor;
        _inputTextField.font = [UIFont fontWithName:@"HelveticaNeue" size:15.5];
        _inputTextField.autocorrectionType = self.autocorrectionType;
        _inputTextField.autocapitalizationType = self.autocapitalizationType;
        _inputTextField.delegate = self;
        _inputTextField.backspaceDelegate = self;
        _inputTextField.placeholder = self.placeholderText;
        _inputTextField.accessibilityLabel = self.inputTextFieldAccessibilityLabel ?: NSLocalizedString(@"To", nil);
        _inputTextField.inputAccessoryView = self.inputTextFieldAccessoryView;
        [_inputTextField addTarget:self action:@selector(inputTextFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _inputTextField;
}

- (void)setAutocorrectionType:(UITextAutocorrectionType)autocorrectionType
{
    _autocorrectionType = autocorrectionType;
    [self.inputTextField setAutocorrectionType:self.autocorrectionType];
    [self.invisibleTextField setAutocorrectionType:self.autocorrectionType];
}

- (void)setInputTextFieldKeyboardAppearance:(UIKeyboardAppearance)inputTextFieldKeyboardAppearance
{
    _inputTextFieldKeyboardAppearance = inputTextFieldKeyboardAppearance;
    [self.inputTextField setKeyboardAppearance:self.inputTextFieldKeyboardAppearance];
}

- (void)setInputTextFieldKeyboardType:(UIKeyboardType)inputTextFieldKeyboardType
{
    _inputTextFieldKeyboardType = inputTextFieldKeyboardType;
    [self.inputTextField setKeyboardType:self.inputTextFieldKeyboardType];
}

- (void)setAutocapitalizationType:(UITextAutocapitalizationType)autocapitalizationType
{
    _autocapitalizationType = autocapitalizationType;
    [self.inputTextField setAutocapitalizationType:self.autocapitalizationType];
    [self.invisibleTextField setAutocapitalizationType:self.autocapitalizationType];
}

- (void)inputTextFieldDidChange:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenField:didChangeText:)]) {
        [self.delegate tokenField:self didChangeText:textField.text];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    if ([self.delegate respondsToSelector:@selector(tokenFieldDidTapCollapsed:)]) {
        [self.delegate tokenFieldDidTapCollapsed:self];
    } else {
        [self becomeFirstResponder];
    }
}

- (void)didTapToken:(UIView<VENTokenObject> *)token
{
    for (UIView<VENTokenObject> *aToken in self.tokens) {
        if (aToken == token) {
            aToken.highlighted = !aToken.highlighted;
            NSUInteger index = [self.tokens indexOfObject:aToken];
            [self.delegate tokenField:self didTapTokenAtIndex:index];
        } else {
            aToken.highlighted = NO;
        }
    }
    [self setCursorVisibility];
}

- (void)unhighlightAllTokensSettingCursorVisibility:(BOOL)setCursorVisibility
{
    for (UIView<VENTokenObject> *token in self.tokens) {
        token.highlighted = NO;
    }

    if (setCursorVisibility) {
        [self setCursorVisibility];
    }
}

- (void)setCursorVisibility
{
    NSArray *highlightedTokens = [self.tokens filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(UIView<VENTokenObject> *evaluatedObject, NSDictionary *bindings) {
        return evaluatedObject.highlighted;
    }]];

    BOOL visible = [highlightedTokens count] == 0;
    if (visible) {
        [self inputTextFieldBecomeFirstResponder];
    } else {
        [self.invisibleTextField becomeFirstResponder];
    }
}

- (void)updateInputTextField
{
    self.inputTextField.placeholder = [self.tokens count] ? nil : self.placeholderText;
}

- (void)focusInputTextField
{
    CGPoint contentOffset = self.scrollView.contentOffset;
    CGFloat targetY = self.inputTextField.frame.origin.y + [self heightForToken] - self.maxHeight;
    if (targetY > contentOffset.y) {
        [self.scrollView setContentOffset:CGPointMake(contentOffset.x, targetY) animated:NO];
    }
}

- (void)updateLastTokenSeperator
{
    VENToken *token = self.tokens.lastObject;
    if (!token) {
        return;
    }

    NSString *title = [self titleForTokenAtIndex:[self.tokens count] - 1];
    BOOL showSeparator = self.inputTextField.isFirstResponder;
    [token setTitleText:title showSeparator:showSeparator];
}

#pragma mark - Data Source

- (NSString *)titleForTokenAtIndex:(NSUInteger)index
{
    if ([self.dataSource respondsToSelector:@selector(tokenField:titleForTokenAtIndex:)]) {
        return [self.dataSource tokenField:self titleForTokenAtIndex:index];
    }

    return [NSString string];
}

- (NSUInteger)numberOfTokens
{
    if ([self.dataSource respondsToSelector:@selector(numberOfTokensInTokenField:)]) {
        return [self.dataSource numberOfTokensInTokenField:self];
    }

    return 0;
}

- (NSString *)collapsedTextWithSize:(CGSize)size
{
    if ([self.dataSource respondsToSelector:@selector(tokenFieldCollapsedText:fittingWidth:)]) {
        return [self.dataSource tokenFieldCollapsedText:self fittingWidth:size.width];
    }

    return @"";
}

- (Class)subclassForTokens
{
    Class defaultClass = [VENToken class];

    if ([self.dataSource respondsToSelector:@selector(subclassForTokensInTokenField:)]) {
        Class providedSubclass = [self.dataSource subclassForTokensInTokenField:self];
        if ([providedSubclass isSubclassOfClass:[UIView class]]
            && [providedSubclass conformsToProtocol:@protocol(VENTokenObject)]) {
            return providedSubclass;
        }
    }

    return defaultClass;
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField != self.invisibleTextField && [self.delegate respondsToSelector:@selector(tokenField:didEnterText:)]) {
        if ([textField.text length]) {
            [self.delegate tokenField:self didEnterText:textField.text];
        }
    }

    return NO;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.inputTextField) {
        [self unhighlightAllTokensSettingCursorVisibility:YES];
        [self updateLastTokenSeperator];
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    if (textField == self.invisibleTextField) {
        __weak VENTokenField *weakSelf = self;
        // Let first responder get moved correctly
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!weakSelf || weakSelf.invisibleTextField.isFirstResponder) {
                return;
            }

            for (UIView<VENTokenObject> *token in self.tokens) {
                token.highlighted = NO;
            }
            [self updateLastTokenSeperator];
        });
        return;
    }

    if ([self.delegate respondsToSelector:@selector(tokenField:didEnterText:)]) {
        if ([textField.text length]) {
            [self.delegate tokenField:self didEnterText:textField.text];
        }
    }

    [self updateLastTokenSeperator];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField != self.invisibleTextField) {
        [self unhighlightAllTokensSettingCursorVisibility:YES];
    }

    BOOL hasHighlightedToken = NO;
    for (UIView<VENTokenObject> *token in self.tokens) {
        if (token.highlighted) {
            hasHighlightedToken = YES;
            break;
        }
    }

    if (hasHighlightedToken) {
        [self textFieldDidEnterBackspace:(VENBackspaceTextField*) textField];
        return YES;
    } else {
        if ([self.delegate respondsToSelector:@selector(tokenField:shouldChangeCharactersInRange:replacementString:)]) {
            return [self.delegate tokenField:self shouldChangeCharactersInRange:range replacementString:string];
        }

        return YES;
    }
}


#pragma mark - VENBackspaceTextFieldDelegate

- (void)textFieldDidEnterBackspace:(VENBackspaceTextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(tokenField:didDeleteTokenAtIndex:)] && [self numberOfTokens]) {
        BOOL didDeleteToken = NO;
        for (UIView<VENTokenObject> *token in self.tokens) {
            if (token.highlighted) {
                [self.delegate tokenField:self didDeleteTokenAtIndex:[self.tokens indexOfObject:token]];
                didDeleteToken = YES;
                break;
            }
        }
        if (!didDeleteToken) {
            UIView<VENTokenObject> *lastToken = [self.tokens lastObject];
            lastToken.highlighted = YES;
        }
        [self setCursorVisibility];
    }
}

@end
