//
//  CCCPost.m
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import "CCCPost.h"

NSString * const kPostId = @"id";
NSString * const kUserKey = @"user";
NSString * const kUserNameKey = @"username";
NSString * const kAvatarImageKey = @"avatar_image";
NSString * const kAvatarImageKeyUrl = @"url";
NSString * const kPostText = @"text";
NSString * const kAvatarKey = @"avatar";

@interface CCCPost ()

- (void)loadAvatar;

@property (nonatomic, copy) NSDictionary *properties;
@property (nonatomic, strong) UIImage *avatar;

@end

@implementation CCCPost

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
   self = [super init];
   
   if ( self ) {
      self.properties = dictionary;
      [self loadAvatar];
   }
   
   return self;
}

- (BOOL)isEqual:(id)object {
   
   if ( self == object ) {
      return YES;
   }
   
   if ( ![object isKindOfClass:[CCCPost class]] ) {
      return NO;
   }
   
   return [self isEqualToPost:object];
}

- (BOOL)isEqualToPost:(CCCPost *)post {
   return ([self postId] == [post postId]);
}

- (NSUInteger)hash {
   return [[self postId] integerValue];
}

- (NSString *)description {
   return [NSString stringWithFormat:@"<CCCPost: %p> %@", self, self.properties];
}

- (NSString *)userName {
   
   NSString *userName = nil;
   
   if ( [self.properties objectForKey:kUserKey] ) {
      userName = [[self.properties objectForKey:kUserKey] objectForKey:kUserNameKey];
   }
   
   return userName;
}

- (NSString *)postText {
   NSString *postText = nil;
   
   postText = [self.properties objectForKey:kPostText];
   
   return postText;
}

- (NSNumber *)postId {
   NSNumber *postId = 0;
   NSString *idString = nil;
   
   if ( [self.properties objectForKey:kPostId] ) {
      idString = [self.properties objectForKey:kPostId];
      postId = @([idString integerValue]);
   }
   
   return postId;
}

- (void)setAvatar:(UIImage *)avatar {
   _avatar = avatar;
   
   [[NSNotificationCenter defaultCenter] postNotificationName:kAvatarKey object:self];
}

#pragma mark - NSCopying

- (instancetype)copyWithZone:(NSZone *)zone {
   return [[CCCPost alloc] initWithDictionary:self.properties];
}

#pragma mark - private

- (void)loadAvatar {
   
   dispatch_async(dispatch_get_global_queue(0, 0), ^{
      UIImage *image = nil;
      NSData *imageData = nil;
      NSString *imageURL = nil;
      
      if ( [self.properties objectForKey:kUserKey] ) {
         if ( [[self.properties objectForKey:kUserKey] objectForKey:kAvatarImageKey] ) {
            imageURL = [[[self.properties objectForKey:kUserKey] objectForKey:kAvatarImageKey] objectForKey:kAvatarImageKeyUrl];
         }
      }
      
      if ( imageURL ) {
         
      }
      
      imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:imageURL]];
      image = [UIImage imageWithData:imageData];
      
      self.avatar = image;
      
   });
   
}

@end
