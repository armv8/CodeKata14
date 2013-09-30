//
//  ZXTrigram.m
//  CodeKata14
//
//  Created by Zaheer Naby on 9/27/13.
//  Copyright (c) 2013 Zaheer Naby. All rights reserved.
//

#import "ZXNGram.h"
#include "Common.h"

@interface ZXNGram()
{
    NSString * _bookContents;
    NSMutableArray * _wordArray;
    NSMutableDictionary * _ngramDictionary;
    NSString * _startPhrase;
}

@end

@implementation ZXNGram

-(id) init
{
    self = [super init];
    if(self) {
        _ngramSize = kDefaultNGramSize;
        _maxOutputLength = kDefaultMaxOutputLength;
    }
    return self;
}

#pragma mark - Regular Expressions Search
-(BOOL) findPhrase:(NSString * ) phrase inString:(NSString * ) string
{
    NSString * regexPattern  = [NSString stringWithFormat:@"^%@", phrase];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSRange stringRange  = NSMakeRange(0, string.length);
    NSUInteger matchCount  =  [regex numberOfMatchesInString:string options:0 range:stringRange];
    if(matchCount > 0)
        return YES;
    else
        return NO;
}

-(NSString *) findPhrase:(NSString * ) phrase inDictionary:(NSDictionary * ) ngramDictionary
{
    NSString * regexPattern  = [NSString stringWithFormat:@"^%@", phrase];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:0
                                                                             error:&error];
    
    
    //Find a similar key
    for(NSString * key in ngramDictionary) {
        NSRange keyRange  = NSMakeRange(0, key.length);
        NSUInteger matchCount  =  [regex numberOfMatchesInString:key options:0 range:keyRange];
        if(matchCount > 0)
            return key;
    }
    return nil;
}

#pragma mark - Load Book
-(void) loadBookFromFile:(NSString *) fileName error:(NSError **) error
{
    //Check to make sure we have a valid file name.
    if(!fileName) {
        NSString * errorMessage = [NSString stringWithFormat:LocalString(@"ERROR_FILENAME_IS_NULL")];
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorBookFileIsNull userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        _bookLoaded = NO;
        return;
    }

    NSString * fullFileLocation =  [[NSBundle mainBundle] pathForResource:fileName ofType:LocalString(@"BOOK_FILE_EXTENTION")];
    NSError * stringError = nil;
    _bookContents = [NSString stringWithContentsOfFile:fullFileLocation encoding:NSUTF8StringEncoding error:&stringError];
    
    if(stringError) {
        NSString * errorMessage = [NSString stringWithFormat:LocalString(@"ERROR_FILE_LOAD_FAILED_FORMAT"), fullFileLocation,  [stringError localizedDescription]];
        NSLog(@"%@", errorMessage);
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorBookFileNotFound userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
        _bookLoaded  = NO;
        return;
    }
    else {
        _bookLoaded = YES;
    }
}


-(void) generateWordArrayStartingWithPhrase:(NSString *) phrase error:(NSError **) error;
{
    
    NSUInteger startPosition = 0;
    NSError *regexError = nil;

    if(_bookContents == nil) {
        NSLog(LocalString(@"ERROR_BOOK_NOT_LOADED"));
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorBookNotLoaded userInfo:@{NSLocalizedDescriptionKey:LocalString(@"ERROR_BOOK_NOT_LOADED")}];
        return;
    }
    
    if(phrase != nil)
    {
        NSRegularExpression * phraseRegex = [NSRegularExpression regularExpressionWithPattern:phrase options:0 error:&regexError];
        NSRange bookRange = NSMakeRange(0, _bookContents.length);
        
        NSTextCheckingResult * firstMatch = [phraseRegex firstMatchInString:_bookContents options:0 range:bookRange];
        startPosition = firstMatch.range.location;
    }

    //NSString * regexPattern  = @"[a-zA-Z0-9,'.\";:’\?!\r\n]+";
     NSString * regexPattern  = @"[a-zA-Z0-9,'.;:’\?!]+";
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexPattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&regexError];
    
    NSRange bookRange  = NSMakeRange(startPosition, _bookContents.length - startPosition);
    
    NSUInteger wordCount  =  [regex numberOfMatchesInString:_bookContents options:0 range:bookRange];
    _wordArray = [[NSMutableArray alloc] initWithCapacity:wordCount];
    
    NSArray * wordsMatches = [regex matchesInString:_bookContents options:0 range:bookRange];
    for(NSTextCheckingResult * wordMatch in wordsMatches)
    {
        NSRange wordRange = wordMatch.range;
        NSString * word = [_bookContents substringWithRange:wordRange];
        [_wordArray addObject:word];
    }
    
    //Create a copy of the phrased used to generate word array.
    if(phrase != nil)
        _startPhrase = [phrase copy];
    else
        _startPhrase = nil; 
}

#pragma mark - Generate NGram Dictionary
-(void) generateDictionaryStartingWithPhrase:(NSString *) phrase error:(NSError **) error
{

    //Generate a word array if we haven't or if the seedPhrase has changed.
    if(_wordArray == nil || ![_startPhrase isEqualToString:phrase]) {
        NSError * generateWordArrayError = nil;
        [self generateWordArrayStartingWithPhrase:phrase error:&generateWordArrayError];
    }
    
    _ngramDictionary = [[NSMutableDictionary alloc] init];
    
    NSUInteger arraySize = [_wordArray count];
    NSUInteger startPosition = _ngramSize;
    
    //Since we're creating trigrams, start at count value of 2.
    for(NSUInteger wc = startPosition; wc < arraySize+1; wc++)
    {
        NSMutableString * keyString = [[NSMutableString alloc] init];
        NSString * value = nil;
        
        [keyString appendString:_wordArray[wc-(_ngramSize)]];
        for(NSUInteger kc = _ngramSize-1; kc > 0; kc--) {
            [keyString appendFormat:@" %@",_wordArray[wc-kc]];
        }
        
        if(wc < arraySize)
            value = _wordArray[wc];
        
        //try to find existing mutable array;
        NSMutableArray * valueArray = [_ngramDictionary objectForKey:keyString];
        
        //create a new array containing the object if null.
        if(valueArray ==  nil) {
            valueArray = [[NSMutableArray alloc] init];
            
            if(value != nil)
                [valueArray addObject:value];
        }
        else {
            BOOL addValue = YES;
            if(value != nil) {
                for(NSString * existingValue in valueArray)
                    if([existingValue isEqualToString:value])
                        addValue = NO;
                
                if(addValue)
                    [valueArray addObject:value];
            }
        }
        [_ngramDictionary setObject:valueArray forKey:keyString];
        
    }
}

#pragma mark - Generate Random Phrase
-(NSString *) generateRandomPhraseStartWithPhrase:(NSString *) beginPhrase error:(NSError **)error;
{
    
    if(!_bookLoaded) {
        NSLog(LocalString(@"ERROR_BOOK_NOT_LOADED"));
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorBookNotLoaded userInfo:@{NSLocalizedDescriptionKey: LocalString(@"ERROR_BOOK_NOT_LOADED")}];
        return nil;
    }
    
    //Input Validation: Check that the ngram phrase key length must be at least 2.
    if(_ngramSize < 2) {
        NSLog(LocalString(@"ERROR_NGRAM_SIZE_TOO_SHORT"));
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorNGramTooShort userInfo:@{NSLocalizedDescriptionKey: LocalString(@"ERROR_NGRAM_SIZE_TOO_SHORT")}];
        return nil;
    }
    
    //Input Validation: Check that start phrase is not nil
    if(beginPhrase == nil) {
        NSLog(LocalString(@"ERROR_SEARCH_PHRASE_IS_NIL"));
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorSearchPhraseIsNil userInfo:@{NSLocalizedDescriptionKey: LocalString(@"ERROR_SEARCH_PHRASE_IS_NIL")}];
        return nil;
    }
    
    //Input Validation: Check that start phase is equal to the n gram phrase length
    NSUInteger phraseWordCount = [[beginPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] count];
    if(phraseWordCount != _ngramSize) {
        NSLog(LocalString(@"ERROR_SEARCH_PHRASE_WORD_COUNT_INVALID"));
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorSearchPhraseWordCountInvalid userInfo:@{NSLocalizedDescriptionKey: LocalString(@"ERROR_SEARCH_PHRASE_WORD_COUNT_INVALID")}];
        return nil;
    }
    
    //Generate ngram dictionary if uninitialized or phrase changed.
    if(_ngramDictionary == nil || ![_startPhrase isEqualToString:beginPhrase])
    {
        NSError * generateDictionaryError = nil;
        [self generateDictionaryStartingWithPhrase:beginPhrase error:&generateDictionaryError];
        
        if(generateDictionaryError) {
            NSLog(LocalString(@"ERROR_GENERATING_DICTIONARY"));
            *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorGeneratingPhraseDictionary userInfo:@{NSLocalizedDescriptionKey:LocalString(@"ERROR_GENERATING_DICTIONARY")}];
            return nil;
        }
    }
    
    //Find matching phrase in ngram dictionary.
    NSString * matchingPhrase = [self findPhrase:beginPhrase inDictionary:_ngramDictionary];
    if(matchingPhrase == nil) {
        NSLog(LocalString(@"ERROR_NO_MATCH_FOUND"));
        *error = [[NSError alloc] initWithDomain:kErrorDomain code:kNGRAMErrorNoMatchFound userInfo:@{NSLocalizedDescriptionKey:LocalString(@"ERROR_NO_MATCH_FOUND")}];
        return nil;
    }
    
    NSMutableString * searchPhrase = [[NSMutableString alloc] init];
    [searchPhrase appendString:matchingPhrase];
    
    NSMutableString * generatedTextString = [[NSMutableString alloc] init];
    [generatedTextString appendString:matchingPhrase];
    
    NSUInteger wordCount =   [[searchPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] count];
    NSInteger index;
    
    //Limit word count to prevent heap overflow.
    while(wordCount <= _maxOutputLength) {
        NSArray * valueArray =  [_ngramDictionary objectForKey:searchPhrase];
        if(valueArray == nil)
            return generatedTextString;
        
        NSUInteger valueArraySize = [valueArray count];
        
        if(valueArraySize > 0)
            index = arc4random() % valueArraySize;
        else
            return generatedTextString;
        
        NSString * word = valueArray[index];
        [generatedTextString appendFormat:@" %@", word];
        wordCount++;
        
        NSArray * splitSearchPhrase = [searchPhrase componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        searchPhrase =  nil;
        
        searchPhrase = [[NSMutableString alloc] init];
        [searchPhrase appendString:splitSearchPhrase[1]];
        
        for(int kc = 2; kc < _ngramSize; kc++) {
            [searchPhrase appendFormat:@" %@", splitSearchPhrase[kc]];
        }
        
        [searchPhrase appendFormat:@" %@", word];
    }
    return generatedTextString;
}


@end
