//
//  Quotes.m
//  QuoteSmith
//
//  Created by waffles on 6/5/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "Quotes.h"

@interface Quotes() {
    NSArray *quoteArray;
}
@end

static int current_quote = 0;

@implementation Quotes

- (NSDictionary *) randomQuote
{
    NSMutableDictionary *r = [[NSMutableDictionary alloc] init];
    int q_index = rand() % [quoteArray count];
    q_index = current_quote % [quoteArray count];
    NSDictionary *quoteIndex = [quoteArray objectAtIndex:q_index];
    NSError* error = nil;
    
    NSString* fileName = [[quoteIndex[@"file_path"] lastPathComponent] stringByDeletingPathExtension];
    NSString* extension = [quoteIndex[@"file_path"] pathExtension];
    
    NSString *quoteFilePath = [[NSBundle mainBundle] pathForResource:fileName ofType:extension];
    NSData* quoteData = [NSData dataWithContentsOfFile:quoteFilePath];
    NSDictionary *quote = [NSJSONSerialization JSONObjectWithData:quoteData
                                                 options:kNilOptions error:&error];
    r[@"quote"]          = quote[@"quote"];
    r[@"author"]         = quote[@"page_title"];
    r[@"quote_location"] = quote[@"quote"];
    r[@"author_source"]  = quote[@"quote"];
    r[@"author_bio"]     = quote[@"page_bio"];
    r[@"author_url"]     = quote[@"page_url"];
    NSArray *words = [r[@"quote"] componentsSeparatedByString:@" "];
    r[@"words"] = [words copy];
    NSLog(@"%@", quote);
    current_quote++;
    return [[NSDictionary alloc] initWithDictionary:r];
}

- (void) loadIndex
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"dat"];
    NSLog(@"Attempting to load quote index");
    NSData* data = [NSData dataWithContentsOfFile:filePath];
    NSError* error = nil;
    quoteArray = [NSJSONSerialization JSONObjectWithData:data
                                                options:kNilOptions error:&error];
    if (quoteArray == nil) {
        NSLog(@"Loading quote index failed");
        exit (0);
    }
    return;
}

@end
