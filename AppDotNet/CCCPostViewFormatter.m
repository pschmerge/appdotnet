//
//  CCCPostViewFormatter.m
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import "CCCPostViewFormatter.h"

static const NSUInteger kTextViewHorizontalPadding = 5;
static const NSUInteger kTextVieVerticalPadding = 10;

@implementation CCCPostViewFormatter

+ (NSMutableAttributedString *)highlightHashTagsInText:(NSString *)text highlightColor:(UIColor *)highlightColor {
   NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text];
   
   // this regular expression should probably be smarter, but it works
   NSRegularExpression *regEx = [NSRegularExpression regularExpressionWithPattern:@"#[a-zA-z0-9]+" options:0 error:nil];
   
   [regEx enumerateMatchesInString:text options:0 range:NSMakeRange(0, [text length]) usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
      
      NSRange range = [result rangeAtIndex:0];
      [string setAttributes:@{NSForegroundColorAttributeName: highlightColor} range:range];
   }];
   
   return string;
}

+ (NSAttributedString *)attributedPostForUser:(NSString *)userName postText:(NSString *)postText highlightColor:(UIColor *)highlightColor {
   NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] init];
   
   NSAttributedString *attributedUserName = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n", userName] attributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:[UIFont systemFontSize]], NSForegroundColorAttributeName: highlightColor}];
   
   NSAttributedString *attributedPostText = [CCCPostViewFormatter highlightHashTagsInText:postText highlightColor:highlightColor];
   
   [attributedString appendAttributedString:attributedUserName];
   [attributedString appendAttributedString:attributedPostText];
   
   return attributedString;
}

+ (CGFloat)heightForAttributedString:(NSAttributedString *)attributedString forWidth:(CGFloat)width {
   
   CGFloat retVal = 0;
   CGFloat labelWidth = width - (kTextViewHorizontalPadding * 2);
   NSStringDrawingOptions options = NSStringDrawingUsesLineFragmentOrigin |
   NSStringDrawingUsesFontLeading;
   
   CGSize size = CGSizeMake(labelWidth, CGFLOAT_MAX);
   
   CGRect boundingRect = [attributedString boundingRectWithSize:size
                                            options:options
                                            context:nil];
   
   retVal = (CGFloat) (ceil(boundingRect.size.height) + (kTextVieVerticalPadding * 2));
   
   return retVal;
}

@end
