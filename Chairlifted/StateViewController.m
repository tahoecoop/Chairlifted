//
//  StateViewController.m
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/22/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import "StateViewController.h"
#import "ChooseResortViewController.h"

@interface StateViewController ()

@property (nonatomic) NSArray *states;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation StateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.states = @[@"Alabama", @"Alaska", @"Arizona", @"Arkansas", @"California", @"Colorado", @"Connecticut", @"Georgia", @"Idaho", @"Illinois", @"Indiana", @"Iowa", @"Maine", @"Maryland", @"Massachusetts", @"Michigan", @"Minnesota", @"Missouri", @"Montana", @"Nevada", @"New Hampshire", @"New Jersey", @"New Mexico", @"New York", @"North Carolina", @"North Dakota", @"Ohio", @"Oregon", @"Pennsylvania", @"Rhode Island", @"South Dakota", @"Tennessee", @"Utah", @"Vermont", @"Virginia", @"Washington", @"West Virginia", @"Wisconsin", @"Wyoming"];

}

#pragma mark - tableview

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.states.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    cell.textLabel.text = self.states[indexPath.row];
    return cell;
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


-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    ChooseResortViewController *vc = segue.destinationViewController;
    vc.state = self.states[self.tableView.indexPathForSelectedRow.row];
    vc.isForPost = self.isForPost;
}



@end
