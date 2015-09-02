//
//  ChooseResortViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/22/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "ChooseResortViewController.h"
#import "EditProfileViewController.h"
#import "User.h"
#import "UIImageView+SpinningFigure.h"
#import "UIImage+SkiSnowboardIcon.h"
#import "CreatePostViewController.h"

@interface ChooseResortViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic) NSArray *resorts;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation ChooseResortViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    activityView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.7];
    UIImageView *spinnerImageView = [[UIImageView alloc] initWithFrame:CGRectMake((self.view.frame.size.width / 2) - 15, (self.view.frame.size.height / 2) - 15, 30, 30)];
    spinnerImageView.image = [UIImage returnSkierOrSnowboarderImage:[[User currentUser].isSnowboarder boolValue]];
    [activityView addSubview:spinnerImageView];
    [self.view addSubview:activityView];
    [spinnerImageView rotateLayerInfinite];

    [NetworkRequests getResortsWithState:self.state andCompletion:^(NSArray *array)
    {
        self.resorts = array;
        [activityView removeFromSuperview];
        [self.tableView reloadData];
    }];
}


#pragma mark - table view

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.resorts.count;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];

    Resort *resort = self.resorts[indexPath.row];
    cell.textLabel.text = resort.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;

}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }

    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)])
    {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }

    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (IBAction)onDoneButtonPressed:(UIBarButtonItem *)sender
{
    if (self.isForPost)
    {
        [self performSegueWithIdentifier:@"UnwindToCreatePost" sender:self];
    }
    else
    {
        [self performSegueWithIdentifier:@"UnwindToEditProfile" sender:self];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"UnwindToEditProfile"])
    {
        EditProfileViewController *vc = segue.destinationViewController;
        Resort *resort = self.resorts[self.tableView.indexPathForSelectedRow.row];
        vc.selectedResort = resort;
    }
    else if ([segue.identifier isEqualToString:@"UnwindToCreatePost"])
    {
        CreatePostViewController *vc = segue.destinationViewController;
        Resort *resort = self.resorts[self.tableView.indexPathForSelectedRow.row];
        vc.selectedResort = resort;
    }
}


@end
