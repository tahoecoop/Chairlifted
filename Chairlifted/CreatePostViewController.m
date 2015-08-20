//
//  CreatePostViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "CreatePostViewController.h"
#import "Post.h"
#import "UIAlertController+UIImagePicker.h"
#import <AFNetworkReachabilityManager.h>

@interface CreatePostViewController ()

@property (weak, nonatomic) IBOutlet UITextField *postTitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation CreatePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];

//    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//
//        NSLog(@"Reachability changed: %@", AFStringFromNetworkReachabilityStatus(status));
//
//
//        switch (status) {
//            case AFNetworkReachabilityStatusReachableViaWWAN:
//            case AFNetworkReachabilityStatusReachableViaWiFi:
//                // -- Reachable -- //
//                NSLog(@"Reachable");
//                break;
//            case AFNetworkReachabilityStatusNotReachable:
//            default:
//                // -- Not reachable -- //
//                NSLog(@"Not Reachable");
//                break;
//        }
//        
//    }];

}


- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (IBAction)onPostButtonPressed:(UIBarButtonItem *)sender
{

    Post *post = [Post new];
    post.title = self.postTitleTextField.text;
    post.text = self.bodyTextView.text;

    if (self.imageView.image)
    {
        post.image = [PFFile fileWithData: UIImageJPEGRepresentation(self.imageView.image, 1.0)];
    }

    post.author = [User currentUser];
    post.likeCount = 0;
    [post calculateHottness];

    if ([[AFNetworkReachabilityManager sharedManager] isReachable]) {

        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error){
                 [self dismissViewControllerAnimated:YES completion:nil];
             }
             else {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                               [self dismissViewControllerAnimated:YES completion:nil];
                                           }];

                 [alert addAction:dismiss];
                 [self presentViewController:alert animated:YES completion:nil];
             } 
         }];
    } else {
        [post saveEventually];

        UIAlertController *offlineAlert = [UIAlertController alertControllerWithTitle:@"Offline" message:@"You have submitted a post offline. This post will be saved locally for now. Next time you open Chairlifted with Internet, it will automatically be saved." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }];
        [offlineAlert addAction:dismiss];
        [self presentViewController:offlineAlert animated:YES completion:nil];
    }
}


- (IBAction)addPhotoButtonPressed:(UIButton *)sender
{
    UIAlertController *alert = [UIAlertController prepareForImagePicker:self];
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.imageView.image = info[UIImagePickerControllerOriginalImage];
    [self dismissViewControllerAnimated:YES completion:nil];
}



@end
