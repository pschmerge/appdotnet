//
//  CCCPost.h
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const kAvatarKey;

@interface CCCPost : NSObject <NSCopying>

@property (nonatomic, readonly) NSString *userName;
@property (nonatomic, readonly) NSString *postText;
@property (nonatomic, readonly) NSNumber *postId;
@property (nonatomic, readonly) UIImage *avatar;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (BOOL)isEqualToPost:(CCCPost *)post;

@end
