//
//  CCCPostsTableViewCell.m
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import "CCCPostsTableViewCell.h"

@interface CCCPostsTableViewCell ()

@property (nonatomic, weak) IBOutlet UITextView *postTextView;
@property (nonatomic, weak) IBOutlet UIImageView *avatarView;

@end

@implementation CCCPostsTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
   self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
   
   if (self) {
      // Initialization code
   }
   
   return self;
}

- (void)awakeFromNib {
   
   CGFloat cornerRadius = CGRectGetMidX(self.avatarView.bounds) / 2.0;
   
   self.avatarView.layer.cornerRadius = cornerRadius;
   self.avatarView.layer.masksToBounds = YES;
   self.avatarView.image = nil;
}

- (void)setPostText:(NSAttributedString *)postText {
   self.postTextView.attributedText = postText;
}

- (void)setAvatarImage:(UIImage *)image {
   self.avatarView.image = image;
}

- (void)prepareForReuse {
   [super prepareForReuse];
   
   self.avatarView.image = nil;
}

@end
