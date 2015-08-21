//
//  DashboardViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/17/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "GroupsViewController.h"
#import "NetworkRequests.h"
#import "GroupCustomTableViewCell.h"
#import "NSDate+TimePassage.h"
#import "JoinGroup.h"
#import "GroupFeedViewController.h"

@interface GroupsViewController ()
@property (weak, nonatomic) IBOutlet UISegmentedControl *segControl;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) NSArray *myGroups;
@property (nonatomic) NSMutableArray *allGroups;
@property (nonatomic) NSArray *pendingGroups;



@end

@implementation GroupsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [NetworkRequests getMyGroupsWithCompletion:^(NSArray *array)
    {
        self.myGroups = array;
        [self.tableView reloadData];
    }];
}

- (IBAction)onSegControlToggle:(UISegmentedControl *)sender
{
    if (self.segControl.selectedSegmentIndex == 0)
    {
        if (!self.myGroups.count > 0)
        {
            [NetworkRequests getMyGroupsWithCompletion:^(NSArray *array)
             {
                 self.myGroups = array;
                 [self.tableView reloadData];
             }];
        }
        [self.tableView reloadData];
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        if (!self.allGroups.count > 0)
        {
            [NetworkRequests getAllGroupsWithCompletion:^(NSArray *array)
             {
                 self.allGroups = [NSMutableArray arrayWithArray:array];
                 [self.tableView reloadData];
             }];
        }
        else
        {
            [self.tableView reloadData];
        }
    }
}


- (IBAction)onAddButtonPressed:(UIBarButtonItem *)button
{
    UIAlertController *newGroup = [UIAlertController alertControllerWithTitle:@"Create Group" message:@"Give your group a crunchy name!" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *save = [UIAlertAction actionWithTitle:@"Save" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action)
    {
        UITextField *textField = [[newGroup textFields]firstObject];
        Group *group = [Group new];
        group.name = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        group.memberQuantity = 1;
        group.mostRecentPost = nil;
        [group saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
        {
            if (succeeded)
            {
                JoinGroup *joinGroup = [JoinGroup new];
                joinGroup.group = group;
                joinGroup.groupName = group.name;
                joinGroup.user = [User currentUser];
                joinGroup.lastViewed = [NSDate date];
                [joinGroup saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                 {
                     [self dismissViewControllerAnimated:YES completion:nil];
                     self.myGroups = nil;
                     self.allGroups = nil;

                     [self.segControl sendActionsForControlEvents:UIControlEventValueChanged];

                 }];
            }
        }];
    }];

    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }];

    [newGroup addTextFieldWithConfigurationHandler:^(UITextField *textField)
    {
        textField.placeholder = @"Group name";
    }];

    [newGroup addAction:save];
    [newGroup addAction:cancel];
    [self presentViewController:newGroup animated:YES completion:nil];
}

#pragma mark - table View Methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.segControl.selectedSegmentIndex == 0)
    {
        return self.myGroups.count;
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        return self.allGroups.count;
    }
    else
    {
        return 0;
    }

}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupCustomTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    JoinGroup *joinGroup;

    if (self.segControl.selectedSegmentIndex == 0)
    {
        joinGroup = self.myGroups[indexPath.row];
    }
    else if (self.segControl.selectedSegmentIndex == 1)
    {
        joinGroup = self.allGroups[indexPath.row];

    }
    Group *group = joinGroup.group;
    cell.groupNameLabel.text = group.name;
    cell.memberQuantityLabel.text = [NSString stringWithFormat:@"%i members", group.memberQuantity];
    cell.lastUpdatedLabel.text = [NSDate determineTimePassed:group.mostRecentPost];

    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
    if ([segue.identifier isEqualToString:@"GroupFeedSegue"])
    {
        GroupFeedViewController *vc = segue.destinationViewController;
        JoinGroup *joinGroup;
        
        if (self.segControl.selectedSegmentIndex == 0)
        {
            joinGroup = self.myGroups[self.tableView.indexPathForSelectedRow.row];
        }
        else if (self.segControl.selectedSegmentIndex == 1)
        {
            joinGroup = self.allGroups[self.tableView.indexPathForSelectedRow.row];
        }

        vc.group = joinGroup.group;
    }
}



@end
