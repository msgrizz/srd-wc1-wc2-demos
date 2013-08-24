//
//  NSURLRequest+GETParams.m
//  CSR Wireless Sensor
//
//  Created by Davis, Morgan on 3/25/13.
//  Copyright (c) 2013 Plantronics, Inc. All rights reserved.
//

#import "NSURLRequest+GETParams.h"

@implementation NSURLRequest (GETParams)


- (NSDictionary *)GETParams
{
    if ([self.HTTPMethod isEqualToString:@"GET"]) {
        
        NSMutableDictionary *queryParams = [NSMutableDictionary dictionary];
        NSString *urlString = [self.URL absoluteString];
        NSArray *urlComponents = [urlString componentsSeparatedByString:@"&"];
        for (NSString *keyValuePair in urlComponents) {
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents objectAtIndex:0];
            NSArray *questionMarkComponents = [key componentsSeparatedByString:@"?"];
            if ([questionMarkComponents count] > 1) {
                key = questionMarkComponents[1];
            }
            NSString *value = [pairComponents objectAtIndex:1];
            [queryParams setObject:value forKey:key];
        }
        return queryParams;
    }
    return nil;
}

@end

