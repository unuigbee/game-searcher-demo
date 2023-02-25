// Disclaimer: Modified from https://github.com/ReactiveX/RxSwift/blob/main/RxCocoa/Runtime/_RXDelegateProxy.m

#import "include/_CombineDelegateProxy.h"
#import "include/_Combine.h"
#import "include/_CombineObjCRuntime.h"

@interface _CombineDelegateProxy () {
    id __weak __forwardToDelegate;
}

@property (nonatomic, strong) id strongForwardDelegate;

@end

static NSMutableDictionary *voidSelectorsPerClass = nil;

@implementation _CombineDelegateProxy

+(NSSet*)collectVoidSelectorsForProtocol:(Protocol *)protocol {
    NSMutableSet *selectors = [NSMutableSet set];

    unsigned int protocolMethodCount = 0;
    struct objc_method_description *pMethods = protocol_copyMethodDescriptionList(protocol, NO, YES, &protocolMethodCount);

    for (unsigned int i = 0; i < protocolMethodCount; ++i) {
        struct objc_method_description method = pMethods[i];
        if (Combine_is_method_with_description_void(method)) {
            [selectors addObject:SEL_VALUE(method.name)];
        }
    }
            
    free(pMethods);

    unsigned int numberOfBaseProtocols = 0;
    Protocol * __unsafe_unretained * pSubprotocols = protocol_copyProtocolList(protocol, &numberOfBaseProtocols);

    for (unsigned int i = 0; i < numberOfBaseProtocols; ++i) {
        [selectors unionSet:[self collectVoidSelectorsForProtocol:pSubprotocols[i]]];
    }
    
    free(pSubprotocols);

    return selectors;
}

+(void)initialize {
    @synchronized (_CombineDelegateProxy.class) {
        if (voidSelectorsPerClass == nil) {
            voidSelectorsPerClass = [[NSMutableDictionary alloc] init];
        }

        NSMutableSet *voidSelectors = [NSMutableSet set];

#define CLASS_HIERARCHY_MAX_DEPTH 100

        NSInteger  classHierarchyDepth = 0;
        Class      targetClass         = NULL;

        for (classHierarchyDepth = 0, targetClass = self;
             classHierarchyDepth < CLASS_HIERARCHY_MAX_DEPTH && targetClass != nil;
             ++classHierarchyDepth, targetClass = class_getSuperclass(targetClass)
        ) {
            unsigned int count;
            Protocol *__unsafe_unretained *pProtocols = class_copyProtocolList(targetClass, &count);
            
            for (unsigned int i = 0; i < count; i++) {
                NSSet *selectorsForProtocol = [self collectVoidSelectorsForProtocol:pProtocols[i]];
                [voidSelectors unionSet:selectorsForProtocol];
            }
            
            free(pProtocols);
        }

        if (classHierarchyDepth == CLASS_HIERARCHY_MAX_DEPTH) {
            NSLog(@"Detected weird class hierarchy with depth over %d. Starting with this class -> %@", CLASS_HIERARCHY_MAX_DEPTH, self);
#if DEBUG
            abort();
#endif
        }
        
        voidSelectorsPerClass[CLASS_VALUE(self)] = voidSelectors;
    }
}

-(id)_forwardToDelegate {
    return __forwardToDelegate;
}

-(void)_setForwardToDelegate:(id __nullable)forwardToDelegate retainDelegate:(BOOL)retainDelegate {
    __forwardToDelegate = forwardToDelegate;
    if (retainDelegate) {
        self.strongForwardDelegate = forwardToDelegate;
    }
    else {
        self.strongForwardDelegate = nil;
    }
}

-(BOOL)hasWiredImplementationForSelector:(SEL)selector {
    return [super respondsToSelector:selector];
}

-(BOOL)voidDelegateMethodsContain:(SEL)selector {
    @synchronized(_CombineDelegateProxy.class) {
        NSSet *voidSelectors = voidSelectorsPerClass[CLASS_VALUE(self.class)];
        NSAssert(voidSelectors != nil, @"Set of allowed methods not initialized");
        return [voidSelectors containsObject:SEL_VALUE(selector)];
    }
}

-(void)forwardInvocation:(NSInvocation *)anInvocation {
    BOOL isVoid = Combine_is_method_signature_void(anInvocation.methodSignature);
    NSArray *arguments = nil;
    if (isVoid) {
        arguments = Combine_extract_arguments(anInvocation);
        [self _sentMessage:anInvocation.selector withArguments:arguments];
    }
    
    if (self._forwardToDelegate && [self._forwardToDelegate respondsToSelector:anInvocation.selector]) {
        [anInvocation invokeWithTarget:self._forwardToDelegate];
    }

    if (isVoid) {
        [self _methodInvoked:anInvocation.selector withArguments:arguments];
    }
}

// abstract method
-(void)_sentMessage:(SEL)selector withArguments:(NSArray *)arguments {

}

// abstract method
-(void)_methodInvoked:(SEL)selector withArguments:(NSArray *)arguments {

}

-(void)dealloc {
}

@end
