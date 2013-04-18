//
//  PhotoDetailViewController.h
//  FlickerApp
//
//  Created by Rincewind on 17.01.13.
//  Copyright (c) 2013 Rincewind. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SplitViewBarButtonItemPresenter.h"
@interface PhotoDetailViewController : UIViewController <SplitViewBarButtonItemPresenter, UIScrollViewDelegate>

@property (strong, nonatomic) IBOutlet UIScrollView *scrollViewWithImage;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *favButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndi;

@property (nonatomic) NSURL *imageURL;
@property (nonatomic) NSDictionary *photo;
@property (nonatomic, strong) UIManagedDocument *photoDatabase;


-(void) showImageFromCache:(NSData*) pic;

- (IBAction) addFaves:(id)sender;
@end
