//
//  CodeKata14Tests.m
//  CodeKata14Tests
//
//  Created by Zaheer Naby on 9/27/13.
//  Copyright (c) 2013 Zaheer Naby. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ZXNGram.h"
#include "Common.h"

#define INVALID_ERROR_CODE  @"Invalid Error Code. Test Failed." 
#define INVALID_BOOK_STATUS @"Invalid Book Status. Test Failed"
#define GENERATED_TEXT_NOT_NIL @"Generated text is not nil. Test failed" 
#define GENERATED_TEXT_IS_NIL @"Generated text is nil. Test failed"
#define ERROR_OBJ_NOT_NIL   @"Error Object is not nil. Test Failed"


@interface CodeKata14Tests : XCTestCase
{
    ZXNGram * _ngram;
    
}
@end

@implementation CodeKata14Tests

- (void)setUp
{
    [super setUp];
    _ngram = [[ZXNGram alloc] init];
}

- (void)tearDown
{
    [super tearDown];
    _ngram = nil;
}

/**
 * Test loadBookFromFile Function with a null filename.
 */
-(void) testFileLoadWithNilFile
{
    
    NSError * error = nil;
    [_ngram loadBookFromFile:nil error:&error];
    XCTAssertEqual([error code], kNGRAMErrorBookFileIsNull, INVALID_ERROR_CODE);
    XCTAssertFalse(_ngram.bookLoaded, INVALID_BOOK_STATUS);
    
}

/**
 * Test loadBookFromFile Function with an invalid filename.
 */
-(void)testFileLoadWithInvalidFile
{
    NSError * error = nil;
    [_ngram loadBookFromFile:@"INVALID_FILE_NAME" error:&error];
    XCTAssertEqual([error code], kNGRAMErrorBookFileNotFound, INVALID_ERROR_CODE);
    XCTAssertFalse(_ngram.bookLoaded, INVALID_BOOK_STATUS);
}

/**
 * Test loadBookFromFile Function with a valid filename.
 */
-(void) testFileLoadWithValidFile
{
    NSError * error = nil;
    [_ngram loadBookFromFile:@"Test" error:&error];
    
    XCTAssertNil(error, ERROR_OBJ_NOT_NIL);
    XCTAssertTrue(_ngram.bookLoaded, INVALID_BOOK_STATUS);
}

/**
 * Test generateRandomPhraseStartWithPhrase Function nil seed phrase.
 */
-(void) testPhraseGenerationWithNilSeed
{
    NSError * loadBookError = nil;
    [_ngram loadBookFromFile:@"Test" error:&loadBookError];
    XCTAssertEqual([loadBookError code], kNGRAMNoError, INVALID_ERROR_CODE);
    XCTAssertTrue(_ngram.bookLoaded, @"Book load status invalid. Test failed");
    
    NSError * generateTextError = nil;
    
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:nil error:&generateTextError];
    XCTAssertNil(generatedText,  GENERATED_TEXT_NOT_NIL);
    XCTAssertEqual([generateTextError code], kNGRAMErrorSearchPhraseIsNil, INVALID_ERROR_CODE);
    
}

/**
 * Test generateRandomPhraseStartWithPhrase Function without first loading a book.
 */
-(void) testPhraseGenerationWithNoBookLoaded
{
    
    NSError * generatedTextError = nil;
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:@"We telegraphed for" error:&generatedTextError];
    
    XCTAssertNil(generatedText, GENERATED_TEXT_NOT_NIL);
    XCTAssertEqual([generatedTextError code], kNGRAMErrorBookNotLoaded, INVALID_ERROR_CODE);
    
}
/**
 * Test generateRandomPhraseStartWithPhrase Function seed phrase that does not match the ngram size.
 */
-(void) testPhraseGenerationWithMismatchPhraseLength
{
    NSError * loadBookError = nil;
    [_ngram loadBookFromFile:@"Test" error:&loadBookError];
    XCTAssertEqual([loadBookError code], kNGRAMNoError, INVALID_ERROR_CODE);
    XCTAssertTrue(_ngram.bookLoaded, INVALID_BOOK_STATUS);
    
    _ngram.ngramSize = 2;
    
    NSError * generateTextError = nil;
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:@"We telegraphed for" error:&generateTextError];
    XCTAssertNil(generatedText,  GENERATED_TEXT_NOT_NIL);
    XCTAssertEqual([generateTextError code], kNGRAMErrorSearchPhraseWordCountInvalid, INVALID_ERROR_CODE);
}

/**
 * Test generateRandomPhraseStartWithPhrase Function seed phrase that does not exist in the text
 */
-(void) testPhraseGenerationWithNoMatchingPhrase
{
    NSError * loadBookError = nil;
    [_ngram loadBookFromFile:@"Test" error:&loadBookError];
    XCTAssertEqual([loadBookError code], kNGRAMNoError, INVALID_ERROR_CODE);
    XCTAssertTrue(_ngram.bookLoaded, INVALID_BOOK_STATUS);
    
    _ngram.ngramSize = 2;
    
    NSError * generateTextError = nil;
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:@"It is" error:&generateTextError];
    XCTAssertNil(generatedText, GENERATED_TEXT_NOT_NIL);
    XCTAssertEqual([generateTextError code], kNGRAMErrorNoMatchFound, INVALID_ERROR_CODE);
}

/**
 * Test generateRandomPhraseStartWithPhrase Function a matching seed phrase
 */
-(void) testPhraseGenerationWithMatchingPhrase
{
    NSError * loadBookError = nil;
    [_ngram loadBookFromFile:@"Test" error:&loadBookError];
    XCTAssertEqual([loadBookError code], kNGRAMNoError, INVALID_ERROR_CODE);
    XCTAssertTrue(_ngram.bookLoaded, INVALID_BOOK_STATUS);
    
    _ngram.ngramSize = 2;
    
    NSError * generateTextError = nil;
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:@"We telegraphed" error:&generateTextError];
    XCTAssertNotNil(generatedText,  GENERATED_TEXT_IS_NIL);
    XCTAssertNil(generateTextError, INVALID_ERROR_CODE);
}

/**
 * Test generateRandomPhraseStartWithPhrase Function with an invalid ngram size.
 */
-(void) testPhraseGenerationWithInvalidNgramLength
{
    NSError * loadBookError = nil;
    [_ngram loadBookFromFile:@"Test" error:&loadBookError];
    XCTAssertEqual([loadBookError code], kNGRAMNoError, INVALID_ERROR_CODE);
    XCTAssertTrue(_ngram.bookLoaded, INVALID_BOOK_STATUS);
    
    _ngram.ngramSize = 1;
    
    NSError * generateTextError = nil;
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:@"We telegraphed for" error:&generateTextError];
    XCTAssertNil(generatedText, GENERATED_TEXT_NOT_NIL);
    XCTAssertEqual([generateTextError code], kNGRAMErrorNGramTooShort, INVALID_ERROR_CODE);
}


/**
 * Test generateRandomPhraseStartWithPhrase Function with a valid ngram size.
 */
-(void) testPhraseGenerationWithValidNgramLength
{
    NSError * loadBookError = nil;
    [_ngram loadBookFromFile:@"Test" error:&loadBookError];
    XCTAssertEqual([loadBookError code], kNGRAMNoError, INVALID_ERROR_CODE);
    XCTAssertTrue(_ngram.bookLoaded, INVALID_BOOK_STATUS);
    
    _ngram.ngramSize = 3;
    
    NSError * generateTextError = nil;
    NSString * generatedText  = [_ngram generateRandomPhraseStartWithPhrase:@"We telegraphed for" error:&generateTextError];
    XCTAssertNotNil(generatedText,  GENERATED_TEXT_IS_NIL);
    XCTAssertNil(generateTextError, ERROR_OBJ_NOT_NIL);
}


@end

