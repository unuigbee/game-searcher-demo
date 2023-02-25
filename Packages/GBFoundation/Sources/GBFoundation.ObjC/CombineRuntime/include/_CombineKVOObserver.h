// Disclaimer: Modified from https://github.com/ReactiveX/RxSwift/blob/main/RxCocoa/Runtime/include/_RXKVOObserver.h

#import <Foundation/Foundation.h>

/**
 ################################################################################
 This file is part of Combine private API
 ################################################################################
 */

// Exists because if written in Swift, reading unowned is disabled during dealloc process
@interface _CombineKVOObserver : NSObject

-(instancetype)initWithTarget:(id)target
                 retainTarget:(BOOL)retainTarget
                      keyPath:(NSString*)keyPath
                      options:(NSKeyValueObservingOptions)options
                     callback:(void (^)(id))callback;

-(void)dispose;

@end
