//
//  ZXTrigram.h
//  CodeKata14
//
//  Created by Zaheer Naby on 9/27/13.
//  Copyright (c) 2013 Zaheer Naby. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ZXNGram : NSObject

@property (nonatomic, assign) NSUInteger ngramSize;
@property (nonatomic, assign) NSUInteger maxOutputLength;
@property (readonly, nonatomic, assign) BOOL bookLoaded;

-(void) loadBookFromFile:(NSString *) fileName error:(NSError **) error;
-(NSString *) generateRandomPhraseStartWithPhrase:(NSString *) beginPhrase error:(NSError **) error;

@end
