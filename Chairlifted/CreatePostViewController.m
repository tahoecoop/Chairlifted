
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
#import "NetworkRequests.h"
#import "PostTopic.h"
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"

@interface CreatePostViewController ()

@property (weak, nonatomic) IBOutlet UITextField *postTitleTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContentView;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) NSArray *topics;
@property (weak, nonatomic) IBOutlet UIButton *topicButton;
@property (weak, nonatomic) IBOutlet UILabel *textPostPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic) UIView *activityView;

@end

@implementation CreatePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];


    [NetworkRequests getTopicsWithCompletion:^(NSArray *array)
    {
        self.topics = array;
        [self.pickerView reloadAllComponents];
    }];




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
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];



    Post *post = [Post new];
    post.title = self.postTitleTextField.text;
    post.text = self.bodyTextView.text;
    post.postTopic = self.topicButton.titleLabel.text;


    if (self.imageView.image)
    {
        post.image = [PFFile fileWithData: UIImageJPEGRepresentation(self.imageView.image, 1.0)];
    }

    if (self.group)
    {
        post.group = self.group;
        post.isPrivate = self.group.isPrivate;
    }
    else
    {
        post.isPrivate = [NSNumber numberWithBool:NO];
    }

    post.author = [User currentUser];
    post.likeCount = 0;
    [post calculateHottness];

    if ([[AFNetworkReachabilityManager sharedManager] isReachable])
    {

        [post saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (!error)
             {
                 [self dismissViewControllerAnimated:YES completion:nil];
                 [activityView removeFromSuperview];
             }
             else {
                 UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error" message:[NSString stringWithFormat:@"%@", error] preferredStyle:UIAlertControllerStyleAlert];
                 UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Dismiss" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
                 {
                     [self dismissViewControllerAnimated:YES completion:nil];
                 }];

                 [alert addAction:dismiss];
                 [self presentViewController:alert animated:YES completion:nil];
             } 
         }];
    }
    else
    {
        [post saveEventually];

        UIAlertController *offlineAlert = [UIAlertController alertControllerWithTitle:@"Offline" message:@"You have submitted a post offline. This post will be saved locally for now. Next time you open Chairlifted with Internet, it will automatically be saved." preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *dismiss = [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
        {
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
    [self checkIfCanPost];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)onTopicButtonPressed:(UIButton *)button
{


    if ([button.titleLabel.textColor isEqual:[UIColor blueColor]])
    {
        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(button.frame.origin.x, button.frame.origin.y + 30, button.frame.size.width, button.frame.size.height)];
        self.pickerView.delegate = self;
        self.pickerView.dataSource = self;
        [self.pickerView reloadAllComponents];
        [self.scrollViewContentView addSubview:self.pickerView];
        self.imageView.hidden = YES;
        self.uploadPhotoButton.hidden = YES;
        [button setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
     }
    else
    {
        self.imageView.hidden = NO;
        self.uploadPhotoButton.hidden = NO;
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [self.pickerView removeFromSuperview];
    }
    [self checkIfCanPost];
}


- (void)checkIfCanPost
{
    if ([self.postTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && ![self.topicButton.titleLabel.text isEqualToString:@"Topic (required)"] && (self.imageView.image || [self.bodyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0))
    {
        self.saveButton.enabled = YES;
    }
    else
    {
        self.saveButton.enabled = NO;
    }
}

#pragma mark - Picker View Methods


- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    [self.topicButton setTitle:[[pickerView delegate] pickerView:pickerView titleForRow:row forComponent:component] forState:UIControlStateNormal];
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.topics.count;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    PostTopic *postTopic = self.topics[row];
    return postTopic.name;
}

#pragma mark - TextView Methods


-(void)textViewDidChange:(UITextView *)textView
{

    if (textView.text.length > 0)
    {
        self.textPostPlaceholderLabel.hidden = YES;

    }
    else
    {
        self.textPostPlaceholderLabel.hidden = NO;
    }
    [self checkIfCanPost];
}

#pragma mark - Text Field Methods

- (IBAction)editingChanged:(UITextField *)textField
{
    [self checkIfCanPost];
}

#pragma mark - activity indicator methods







@end
