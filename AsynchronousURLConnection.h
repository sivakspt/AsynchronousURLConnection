//
//  AsynchronousURLConnection.h
//
//  Created by Maksym Huk on 10/31/12.
//  Copyright (c) 2012 Maksym Huk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AsynchronousURLConnection : NSObject

// Send request with exact timeout
+ (void)sendRequest:(NSURLRequest *)request completionHandler:(void (^)(NSURLResponse*, NSData*, NSError*))handler;

@end
