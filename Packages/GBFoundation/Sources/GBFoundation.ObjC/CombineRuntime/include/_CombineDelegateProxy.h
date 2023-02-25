// Disclaimer: Modified from https://github.com/ReactiveX/RxSwift/blob/main/RxCocoa/Runtime/include/_RXDelegateProxy.h

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _CombineDelegateProxy : NSObject

@property (nonatomic, weak, readonly) id _forwardToDelegate;

-(void)_setForwardToDelegate:(id __nullable)forwardToDelegate retainDelegate:(BOOL)retainDelegate NS_SWIFT_NAME(_setForwardToDelegate(_:retainDelegate:)) ;

-(BOOL)hasWiredImplementationForSelector:(SEL)selector;
-(BOOL)voidDelegateMethodsContain:(SEL)selector;

-(void)_sentMessage:(SEL)selector withArguments:(NSArray*)arguments;
-(void)_methodInvoked:(SEL)selector withArguments:(NSArray*)arguments;

@end

NS_ASSUME_NONNULL_END
