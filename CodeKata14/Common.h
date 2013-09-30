//
//  Common.h
//  CodeKata14
//
//  Created by Zaheer Naby on 9/28/13.
//  Copyright (c) 2013 Zaheer Naby. All rights reserved.
//

#ifndef CodeKata14_Common_h
#define CodeKata14_Common_h

#define LocalString(x)  NSLocalizedString(x, nil)
#define kErrorDomain    @"com.naby.zaheer.ngram"
#define kDefaultNGramSize 2
#define kDefaultMaxOutputLength 10000

#define kNGRAMNoError                                0
#define kNGRAMErrorBookFileIsNull                   -1000
#define kNGRAMErrorBookFileNotFound                 -1010
#define kNGRAMErrorBookNotLoaded                    -1020
#define kNGRAMErrorNGramTooShort                    -1025
#define kNGRAMErrorGeneratingPhraseDictionary       -1030
#define kNGRAMErrorNoMatchFound                     -1040
#define kNGRAMErrorSearchPhraseIsNil                -1050
#define kNGRAMErrorSearchPhraseWordCountInvalid     -1060
#define KNGRAMErrorSearchPhraseTooShort             -1070



#endif
