//
//  BRMetadata.m
//  PLTDevice
//
//  Created by Morgan Davis on 3/8/14.
//  Copyright (c) 2014 Plantronics. All rights reserved.
//

#import "BRMetadata.h"
#import "NSArray+PrettyPrint.h"


@interface BRMetadata () {
    NSData      *_data;
}

- (id)initWithData:(NSData *)data;
- (void)parseData;

@property(nonatomic,strong,readwrite) NSArray   *commands;
@property(nonatomic,strong,readwrite) NSArray   *settings;
@property(nonatomic,strong,readwrite) NSArray   *events;

@end


@implementation BRMetadata

@dynamic data;

- (void)setData:(NSData *)data
{
    _data = data;
    [self parseData];
}

- (NSData *)data
{
    return _data;
}

#pragma mark - Private

+ (BRMetadata *)metadataWithData:(NSData *)data;
{
    BRMetadata *md = [[[super class] alloc] initWithData:data];
    return md;
}

- (id)initWithData:(NSData *)data
{
    self = [super init];
    self.data = data;
    return self;
}

- (void)parseData
{
    uint16_t payloadOffset = 6;
    
    uint16_t len;
    [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
    payloadOffset += 2;
    len = ntohs(len);
    NSMutableArray *commands = [NSMutableArray array];
    for (int end = payloadOffset+(len*2); payloadOffset<end; payloadOffset+=2) {
        uint16_t cmd;
        [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&cmd length:sizeof(uint16_t)];
        cmd = ntohs(cmd);
        [commands addObject:@(cmd)];
    }
    self.commands = commands;
    
    [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
    payloadOffset += 2;
    len = ntohs(len);
    NSMutableArray *settings = [NSMutableArray array];
    for (int end = payloadOffset+(len*2); payloadOffset<end; payloadOffset+=2) {
        uint16_t stg;
        [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&stg length:sizeof(uint16_t)];
        stg = ntohs(stg);
        [settings addObject:@(stg)];
    }
    self.settings = settings;
    
    [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&len length:sizeof(uint16_t)];
    payloadOffset += 2;
    len = ntohs(len);
    NSMutableArray *events = [NSMutableArray array];
    for (int end = payloadOffset+(len*2); payloadOffset<end; payloadOffset+=2) {
        uint16_t evn;
        [[self.data subdataWithRange:NSMakeRange(payloadOffset, sizeof(uint16_t))] getBytes:&evn length:sizeof(uint16_t)];
        evn = ntohs(evn);
        [events addObject:@(evn)];
    }
    self.events = events;
}

#pragma mark - NSObject

- (NSString *)description
{
    return [NSString stringWithFormat:@"<BRMetadata %p> commands=%@, settings=%@, events=%@",
            self, [self.commands hexDescriptionFromShortIntegerArray], [self.settings hexDescriptionFromShortIntegerArray], [self.events hexDescriptionFromShortIntegerArray]];
}

@end
