//
//  CCCPostViewFormatter.h
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CCCPostViewFormatter : NSObject

+ (NSAttributedString *)attributedPostForUser:(NSString *)userName postText:(NSString *)postText highlightColor:(UIColor *)highlighColor;

+ (CGFloat)heightForAttributedString:(NSAttributedString *)attributedString forWidth:(CGFloat)width;

@end
