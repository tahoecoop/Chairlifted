//
//  CreateCommentWithTextViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/19/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreateCommentWithTextViewController.h"
#import "Comment.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "UIImageView+SpinningFigure.h"

@interface CreateCommentWithTextViewController ()

@property (strong, nonatomic) IBOutlet UILabel *commentTextPlaceholderLabel;
@property (nonatomic) UIToolbar *keyboardToolbarTextview;

@end

@implementation CreateCommentWithTextViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.textView.layer.cornerRadius = self.textView.frame.size.width / 70;

}


- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onSaveButtonPressed:(UIBarButtonItem *)sender
{
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];


    Comment *comment = [Comment new];
    comment.text = self.textView.text;
    comment.author = [User currentUser];
    comment.post = self.post;
    [comment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (succeeded)
         {
             self.post.commentCount++;
             [self.post calculateHottness];
             [self.post saveInBackgroundWithBlock:^(BOOL succeededTwo, NSError *error)
              {
                  if (succeededTwo)
                  {
                      NSDictionary *pushData = @{@"alert" : [NSString stringWithFormat:@"%@ commented on your post!", [User currentUser].displayName],
                                                 @"badge" : @"Increment"};
                      PFPush *push = [PFPush new];
                      [push setChannel:[NSString stringWithFormat:@"comments%@",self.post.author.objectId]];
                      [push setData:pushData];

                      [push sendPushInBackgroundWithBlock:^(BOOL succeededPush, NSError *error)
                       {
                           if (succeededPush)
                           {
                               [activityView removeFromSuperview];
                               [self dismissViewControllerAnimated:YES completion:nil];
                           }
                       }];
                  }
              }];
         }
     }];
}

#pragma mark - Text View Methods

-(BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    self.keyboardToolbarTextview = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 50)];
    self.keyboardToolbarTextview.barStyle = UIBarStyleDefault;
    self.keyboardToolbarTextview.items = [NSArray arrayWithObjects:[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignTextViewKeyboard)], nil];
    [self.keyboardToolbarTextview sizeToFit];
    textView.inputAccessoryView = self.keyboardToolbarTextview;
    return YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 0)
    {
        self.commentTextPlaceholderLabel.hidden = YES;
    }
    else
    {
        self.commentTextPlaceholderLabel.hidden = NO;
    }
}

-(void)resignTextViewKeyboard
{
    [self.textView resignFirstResponder];
}

@end
