//
//  CCCPostsTableViewCell.h
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CCCPostsTableViewCell : UITableViewCell

@property (nonatomic, weak, readonly) UITextView *postTextView;
@property (nonatomic, weak, readonly) UIImageView *avatarView;

- (void)setPostText:(NSAttributedString *)postText;
- (void)setAvatarImage:(UIImage *)image;

@end
