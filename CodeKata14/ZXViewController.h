//
//  ZXViewController.h
//  CodeKata14
//
//  Created by Zaheer Naby on 9/27/13.
//  Copyright (c) 2013 Zaheer Naby. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZXViewController : UIViewController

@property (nonatomic, weak) IBOutlet UISearchBar * searchBar;
@property (nonatomic, weak) IBOutlet UITextView * textArea;
@property (nonatomic, weak) IBOutlet UIButton * generateText;


-(IBAction) generateText:(id)sender;

@end
