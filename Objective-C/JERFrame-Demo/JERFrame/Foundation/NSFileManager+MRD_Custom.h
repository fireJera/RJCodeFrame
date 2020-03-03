//
//  NSFileManager+MRD_Custom.h
//  JERFrame
//
//  Created by super on 2018/11/20.
//  Copyright © 2018 Jeremy. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSFileManager (MRD_Custom)

@property (class, nonatomic, readonly) NSURL * documentsURL;
@property (class, nonatomic, readonly) NSString * documentsPath;
@property (class, nonatomic, readonly) NSURL * cachesURL;
@property (class, nonatomic, readonly) NSString * cachesPath;
@property (class, nonatomic, readonly) NSURL * libraryURL;
@property (class, nonatomic, readonly) NSString * libraryPath;

@end

NS_ASSUME_NONNULL_END
