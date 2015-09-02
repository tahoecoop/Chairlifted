
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
#import "StateViewController.h"

@interface CreatePostViewController ()

@property (weak, nonatomic) IBOutlet UITextField *postTitleTextField;
@property (weak, nonatomic) IBOutlet UITextField *topicTextField;
@property (weak, nonatomic) IBOutlet UITextView *bodyTextView;
@property (weak, nonatomic) IBOutlet UIButton *uploadPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *scrollViewContentView;
@property (nonatomic) UIPickerView *pickerView;
@property (nonatomic) NSArray *topics;
@property (weak, nonatomic) IBOutlet UILabel *textPostPlaceholderLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveButton;
@property (nonatomic) UIView *activityView;
@property (weak, nonatomic) IBOutlet UILabel *selectedResortLabel;
@property (weak, nonatomic) IBOutlet UIButton *tagResortButton;
@property (nonatomic) UIToolbar *keyboardToolBar;
@property (nonatomic) UIView *coverView;
@property (nonatomic) UIToolbar *keyboardToolbarTextview;


@end

@implementation CreatePostViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.selectedResortLabel.hidden = YES;
    NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.scrollViewContentView attribute:NSLayoutAttributeLeading relatedBy:0 toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
    [self.view addConstraint:leftConstraint];

    NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.scrollViewContentView attribute:NSLayoutAttributeTrailing relatedBy:0 toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
    [self.view addConstraint:rightConstraint];

    self.pickerView = [UIPickerView new];
    self.pickerView.dataSource = self;
    self.pickerView.delegate = self;
    [self addToolBarToPicker];
    self.topicTextField.inputView = self.pickerView;

    self.tagResortButton.layer.cornerRadius = self.tagResortButton.frame.size.width / 45;
    self.uploadPhotoButton.layer.cornerRadius = self.uploadPhotoButton.frame.size.width / 45;



    [NetworkRequests getTopicsWithCompletion:^(NSArray *array)
    {
        self.topics = array;
        [self.pickerView reloadAllComponents];
    }];

    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}


- (IBAction)onCancelButtonPressed:(UIBarButtonItem *)sender
{
    [self.view endEditing:YES];
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
    post.postTopic = self.topicTextField.text;


    if (self.imageView.image)
    {
        post.image = [PFFile fileWithData: UIImageJPEGRepresentation(self.imageView.image, 1.0)];
        post.imageThumbnail = [PFFile fileWithData: UIImageJPEGRepresentation(self.imageView.image, 0.25)];
    }

    if (self.group)
    {
        post.group = self.group;
        post.isPrivate = self.group.isPrivate;

        NSDictionary *pushData = @{
                                   @"alert" : [NSString stringWithFormat:@"New group post in %@ from %@", self.group.name, [User currentUser].displayName],
                                   @"badge" : @"Increment"
                                   };

        PFPush *push = [PFPush new];
        [push setChannel:[NSString stringWithFormat:@"group%@", self.group.objectId]];
        [push setData:pushData];
        [push sendPushInBackground];
    }
    else
    {
        post.isPrivate = [NSNumber numberWithBool:NO];
    }

    if (self.selectedResort)
    {
        post.resort = self.selectedResort;
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


- (void)checkIfCanPost
{
    if ([self.postTitleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length > 0 && self.topicTextField.text.length > 0 && (self.imageView.image || [self.bodyTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0))
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
//    self.topicTextField.text = [[pickerView delegate] pickerView:pickerView titleForRow:row forComponent:component];
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


- (void)addToolBarToPicker
{
    if (!self.keyboardToolBar)
    {
        self.keyboardToolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, 44)];
    }
    [self.keyboardToolBar setBarStyle:UIBarStyleDefault];
    [self.keyboardToolBar sizeToFit];

    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc]initWithTitle:@"Done" style:UIBarButtonItemStyleDone target:self action:@selector(resignToolbar:)];

    NSArray *itemsArray = [NSArray arrayWithObjects:doneButton, nil];

    [self.keyboardToolBar setItems:itemsArray];
    self.topicTextField.inputAccessoryView = self.keyboardToolBar;
}

- (void)resignToolbar:(UIBarButtonItem *)sender
{
    PostTopic *postTopic = [self.topics objectAtIndex:[self.pickerView selectedRowInComponent:0]];
    self.topicTextField.text = postTopic.name;
    [self.topicTextField resignFirstResponder];
}


#pragma mark - TextView Methods

-(void)textViewDidBeginEditing:(UITextView *)textView
{


}


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

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.topicTextField)
    {
//        textField.userInteractionEnabled = NO;

//        self.coverView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width,  [[UIScreen mainScreen]bounds].size.height)];
//        self.coverView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
//        [self.coverView endEditing:YES];
//        [self.view addSubview:self.coverView];
//
//        self.pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, [[UIScreen mainScreen]bounds].size.height - 216, [[UIScreen mainScreen]bounds].size.width, 216)];
//        self.pickerView.delegate = self;
//        self.pickerView.dataSource = self;
//        [self.pickerView reloadAllComponents];
//        self.pickerView.backgroundColor = [UIColor whiteColor];
//        [self.coverView addSubview:self.pickerView];

    }
}


-(void)textFieldDidEndEditing:(UITextField *)textField
{
    textField.userInteractionEnabled = YES;
    [textField resignFirstResponder];
    [self checkIfCanPost];
    [self.view endEditing:YES];

}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return NO;
}

- (void)resignTextViewKeyboard
{
    [self.bodyTextView resignFirstResponder];
}

#pragma mark - Segue methods

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ToTagResort"])
    {
        StateViewController *vc = segue.destinationViewController;
        vc.isForPost = YES;
    }
}


-(IBAction)unwindToCreatePost:(UIStoryboardSegue *)segue
{
    self.selectedResortLabel.text = self.selectedResort.name;
    self.selectedResortLabel.hidden = NO;
}



@end
