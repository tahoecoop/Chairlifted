//
//  SearchViewController.h
//  Chairlifted
//
//  Created by Benjamin COOPER on 8/22/15.
//  Copyright (c) 2015 EBB. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GroupCustomTableViewCell.h"
#import "CustomFeedTableViewCell.h"
#import "CustomFeedWithPhotoTableViewCell.h"

@interface SearchViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic) BOOL isGroup;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;


@end
