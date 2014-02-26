//
//  CCCPostsTableViewController.m
//  AppDotNet
//
//  Created by Pierce Schmerge on 2/25/14.
//  Copyright (c) 2014 Pierce Schmerge. All rights reserved.
//

#import "CCCPostsTableViewController.h"
#import "CCCPostsTableViewCell.h"
#import "CCCPost.h"
#import "CCCPostViewFormatter.h"

static NSString * const kCellReuseIdentifier = @"appDotNetPostCell";
static NSString * const kAppDotNetURL = @"https://alpha-api.app.net/stream/0/posts/stream/global";
static NSString * const kDataKey = @"data";

@interface CCCPostsTableViewController ()

@property (nonatomic, strong) NSMutableArray *posts;
@property (nonatomic, strong) NSMutableDictionary *renderedPostCache;
@property (nonatomic, strong) NSMutableDictionary *cachedHeight;
@property (nonatomic, strong) CCCPostsTableViewCell *prototypeCell;

- (IBAction)triggerRefresh:(id)sender;
- (void)fetchData;
- (void)processFetchedData:(NSSet *)set;
- (NSAttributedString *)attributedStringForPost:(CCCPost *)post;
- (void)handleAvatarLoad:(NSNotification *)notification;

@end

@implementation CCCPostsTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
   self = [super initWithStyle:style];

   if ( self ) {

   }
   
   return self;
}

- (void)viewDidLoad {
   [super viewDidLoad];
   
   self.posts = [NSMutableArray new];
   self.renderedPostCache = [NSMutableDictionary dictionary];
   self.cachedHeight = [NSMutableDictionary dictionary];
   
   // register for notifications from posts regarding whether avatars
   // have loaded
   [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleAvatarLoad:) name:kAvatarKey object:nil];
   
   [self fetchData];
}

- (void)didReceiveMemoryWarning {
   [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.posts count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   NSAttributedString *postText = nil;

   CCCPostsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier forIndexPath:indexPath];
   
   CCCPost *post = [self.posts objectAtIndex:indexPath.row];
   
   postText = [self attributedStringForPost:post];
   
   [cell setPostText:postText];
   [cell setAvatarImage:post.avatar];
   
   return cell;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
   
   CGFloat retVal = 0;
   
   NSAttributedString *postText = nil;
   CCCPost *post = [self.posts objectAtIndex:indexPath.row];
   
   if ( !self.prototypeCell ) {
      self.prototypeCell = [tableView dequeueReusableCellWithIdentifier:kCellReuseIdentifier];
   }
   
   // use cached height as much as possible
   if ( [self.cachedHeight objectForKey:post] ) {
      retVal = [[self.cachedHeight objectForKey:post] floatValue];
   }
   else {
      postText = [self attributedStringForPost:post];
      
      retVal = [CCCPostViewFormatter heightForAttributedString:postText forWidth:CGRectGetWidth(self.prototypeCell.postTextView.bounds)];
      
      // make the minimum height for the cell equal to the size of the avatar +
      // the distance from the top of the cell to the start, and then add that delta
      // again to the bottom to pad it evenly.
      if ( retVal < CGRectGetHeight(self.prototypeCell.avatarView.bounds) ) {
         retVal = CGRectGetHeight(self.prototypeCell.avatarView.bounds) + CGRectGetMinY(self.prototypeCell.avatarView.frame) * 2.0;
      }
      
      [self.cachedHeight setObject:@(retVal) forKey:post];
   
   }
   
   return retVal;
}

#pragma mark - private

- (IBAction)triggerRefresh:(id)sender {
   [self fetchData];
}

- (void)fetchData {
   NSURL *url = [[NSURL alloc] initWithString:kAppDotNetURL];
   NSURLRequest *urlRequest = [[NSURLRequest alloc] initWithURL:url];
   
   [NSURLConnection sendAsynchronousRequest:urlRequest
                                      queue:[NSOperationQueue new]
                          completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                             
                             // indicate the refresh has been completed
                             dispatch_sync(dispatch_get_main_queue(), ^{
                                if ( self.refreshControl.refreshing ) {
                                   [self.refreshControl endRefreshing];
                                }
                             });
                             
                             // only attempt to process if error is nil (success)
                             if ( !connectionError ) {
                                // offload the data processing to background queue
                                dispatch_async(dispatch_get_global_queue(0, 0), ^{
                                   NSError *jsonConversionError = nil;
                                   NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonConversionError];
                                   
                                   NSMutableSet *postSet = [NSMutableSet new];
                                   
                                   for ( NSDictionary *postDict in [jsonDictionary objectForKey:kDataKey] ) {
                                      // pass onto for processing as model
                                      CCCPost *post = [[CCCPost alloc] initWithDictionary:postDict];
                                      [postSet addObject:post];
                                   }
                                   
                                   if ( [postSet count] > 0 ) {
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                         [self processFetchedData:postSet];
                                      });
                                   }
                                   
                                });
                             }
                             
                             
      
   }];
}

- (void)processFetchedData:(NSSet *)set {
   
   // app.net documenation states that IDs should be used, in descending order
   // for sorting by time.
   NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"postId" ascending:NO];
   
   NSMutableSet *mutableSet = [[NSMutableSet alloc] initWithArray:self.posts];
   [mutableSet unionSet:set];
   
   NSArray *sortedArray = [[mutableSet allObjects] sortedArrayUsingDescriptors:@[sortDescriptor]];
   self.posts = [NSMutableArray arrayWithArray:sortedArray];
   
   [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
}

// allocating attributed strings is an expensive operation, cache when possible
- (NSAttributedString *)attributedStringForPost:(CCCPost *)post {
   NSAttributedString *postText = nil;
   
   if ( [self.renderedPostCache objectForKey:post.postId] ) {
      postText = [self.renderedPostCache objectForKey:post.postId];
   }
   else {
      postText = [CCCPostViewFormatter attributedPostForUser:post.userName postText:post.postText highlightColor:self.view.tintColor];
      [self.renderedPostCache setObject:postText forKey:post.postId];
   }

   return postText;
}

- (void)handleAvatarLoad:(NSNotification *)notification {

   // update avatars on the main thread...
   dispatch_async(dispatch_get_main_queue(), ^{
      CCCPostsTableViewCell *cell = nil;
      CCCPost *post = notification.object;
      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.posts indexOfObject:post] inSection:0];
      
      cell = (CCCPostsTableViewCell *)[self.tableView cellForRowAtIndexPath:indexPath];
      
      if ( cell ) {
         [cell setAvatarImage:post.avatar];
      }
   });
   
}

@end
