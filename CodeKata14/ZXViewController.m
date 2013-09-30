//
//  ZXViewController.m
//  CodeKata14
//
//  Created by Zaheer Naby on 9/27/13.
//  Copyright (c) 2013 Zaheer Naby. All rights reserved.
//

#import "ZXViewController.h"
#import "ZXNGram.h"
#include "Common.h"

@interface ZXViewController ()
{
    ZXNGram * _ngram;
}
@end

@implementation ZXViewController

-(id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self) {
        _ngram = [[ZXNGram alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    dispatch_queue_t ngramQueue =   dispatch_queue_create("com.naby.zaheer.ngam", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(ngramQueue, ^(void)  {
        [_ngram loadBookFromFile:@"Test3" error:nil];
    });
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}


-(IBAction) generateText:(id)sender
{
    if(_ngram.bookLoaded)
        [self generateStory];
    else
        [self displayBookNotLoadedAlert];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
    
    if(_ngram.bookLoaded)
        [self generateStory];
    else
        [self displayBookNotLoadedAlert];
    
}

-(void) displayBookNotLoadedAlert
{
    UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:LocalString(@"ALERT_ERROR_TITLE") message:LocalString(@"") delegate:nil cancelButtonTitle:LocalString(@"ALERT_ERROR_CANCEL_BUTTON_TITLE") otherButtonTitles:nil];
    
    [alertView show];
}

-(void) generateStory
{
    NSString * searchPhrase = _searchBar.text;
    NSUInteger wordCount  = [[searchPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] count];
    
    //ngramSize must match search phrase word count.
    _ngram.ngramSize = wordCount;
    
    NSError * error = nil;
    
    NSString * generatedText = [_ngram generateRandomPhraseStartWithPhrase:searchPhrase error:&error];
    
    if(error)
    {
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:LocalString(@"ALERT_ERROR_TITLE") message:[error localizedDescription] delegate:nil cancelButtonTitle:LocalString(@"ALERT_ERROR_CANCEL_BUTTON_TITLE") otherButtonTitles:nil];
        
        [errorAlert show];
    }
    else {
        _textArea.text = generatedText;
    }
}

@end
