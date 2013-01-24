//
//  AsynchronousURLConnection.m
//
//  Created by Maksym Huk on 10/31/12.
//  Copyright (c) 2012 Maksym Huk. All rights reserved.
//

#import "AsynchronousURLConnection.h"

@interface AsynchronousURLConnection () <NSURLConnectionDataDelegate>

@end

@implementation AsynchronousURLConnection
{
    NSURLConnection *_connection;
    NSTimer *_timer;
    void (^_handler)(NSURLResponse*, NSData*, NSError*);
    
    NSURLResponse *_response;
    NSMutableData *_data;
}

- (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    _handler = handler;
    _response = nil;
    _data = [NSMutableData data];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _timer = [NSTimer timerWithTimeInterval:request.timeoutInterval
                                         target:self
                                       selector:@selector(requestDidTimeout:)
                                       userInfo:nil
                                        repeats:NO];
        
        _connection = [NSURLConnection connectionWithRequest:request delegate:self];
    });
}

+ (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler
{
    AsynchronousConnection *connection = [[AsynchronousConnection alloc] init];
    [connection sendRequest:request completionHandler:handler];
}

- (void)requestDidTimeout:(NSTimer *)timer
{
    NSURL *url = _connection.currentRequest.URL;
    
    [_connection cancel];
    _connection = nil;
    
    _timer = nil;
    
    _handler(_response, _data, [NSError errorWithDomain:NSPOSIXErrorDomain code:ETIMEDOUT userInfo:@{ NSLocalizedDescriptionKey : [NSString stringWithFormat:@"Connection timed out to URL: %@", url] }]);
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [_timer invalidate];
    _timer = nil;
    
    _handler(_response, _data, error);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    _response = response;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [_timer invalidate];
    _timer = nil;
    
    _handler(_response, _data, nil);
}

@end