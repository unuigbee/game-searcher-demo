// Disclaimer: Modified from https://github.com/ReactiveX/RxSwift/blob/main/RxCocoa/Runtime/include/_RX.h

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
/**
 ################################################################################
 This file is part of Combine private API
 ################################################################################
 */

#if        TRACE_RESOURCES >= 2
#   define DLOG(...)         NSLog(__VA_ARGS__)
#else
#   define DLOG(...)
#endif

#if        DEBUG
#   define ABORT_IN_DEBUG    abort();
#else
#   define ABORT_IN_DEBUG
#endif


#define SEL_VALUE(x)      [NSValue valueWithPointer:(x)]
#define CLASS_VALUE(x)    [NSValue valueWithNonretainedObject:(x)]
#define IMP_VALUE(x)      [NSValue valueWithPointer:(x)]

/**
 Checks that the local `error` instance exists before assigning it's value by reference.
 This macro exists to work around static analysis warnings — `NSError` is always assumed to be `nullable`, even though we explicitly define the method parameter as `nonnull`. See http://www.openradar.me/21766176 for more details.
 */
#define Combine_THROW_ERROR(errorValue, returnValue) if (error != nil) { *error = (errorValue); } return (returnValue);

#define Combine_CAT2(_1, _2) _Combine_CAT2(_1, _2)
#define _Combine_CAT2(_1, _2) _1 ## _2

#define Combine_ELEMENT_AT(n, ...) Combine_CAT2(_Combine_ELEMENT_AT_, n)(__VA_ARGS__)
#define _Combine_ELEMENT_AT_0(x, ...) x
#define _Combine_ELEMENT_AT_1(_0, x, ...) x
#define _Combine_ELEMENT_AT_2(_0, _1, x, ...) x
#define _Combine_ELEMENT_AT_3(_0, _1, _2, x, ...) x
#define _Combine_ELEMENT_AT_4(_0, _1, _2, _3, x, ...) x
#define _Combine_ELEMENT_AT_5(_0, _1, _2, _3, _4, x, ...) x
#define _Combine_ELEMENT_AT_6(_0, _1, _2, _3, _4, _5, x, ...) x

#define Combine_COUNT(...) Combine_ELEMENT_AT(6, ## __VA_ARGS__, 6, 5, 4, 3, 2, 1, 0)
#define Combine_EMPTY(...) Combine_ELEMENT_AT(6, ## __VA_ARGS__, 0, 0, 0, 0, 0, 0, 1)

/**
 #define SUM(context, index, head, tail) head + tail
 #define MAP(context, index, element) (context)[index] * (element)

 Combine_FOR(numbers, SUM, MAP, b0, b1, b2);

 (numbers)[0] * (b0) + (numbers)[1] * (b1) + (numbers[2]) * (b2)
 */

#define Combine_FOREACH(context, concat, map, ...) Combine_FOR_MAX(Combine_COUNT(__VA_ARGS__), _Combine_FOREACH_CONCAT, _Combine_FOREACH_MAP, context, concat, map, __VA_ARGS__)
#define _Combine_FOREACH_CONCAT(index, head, tail, context, concat, map, ...) concat(context, index, head, tail)
#define _Combine_FOREACH_MAP(index, context, concat, map, ...) map(context, index, Combine_ELEMENT_AT(index, __VA_ARGS__))

/**
 #define MAP(context, index, item) (context)[index] * (item)

 Combine_FOR_COMMA(numbers, MAP, b0, b1);

 ,(numbers)[0] * b0, (numbers)[1] * b1
 */
#define Combine_FOREACH_COMMA(context, map, ...) Combine_CAT2(_Combine_FOREACH_COMMA_EMPTY_, Combine_EMPTY(__VA_ARGS__))(context, map, ## __VA_ARGS__)
#define _Combine_FOREACH_COMMA_EMPTY_1(context, map, ...)
#define _Combine_FOREACH_COMMA_EMPTY_0(context, map, ...) , Combine_FOR_MAX(Combine_COUNT(__VA_ARGS__), _Combine_FOREACH_COMMA_CONCAT, _Combine_FOREACH_COMMA_MAP, context, map, __VA_ARGS__)
#define _Combine_FOREACH_COMMA_CONCAT(index, head, tail, context, map, ...) head, tail
#define _Combine_FOREACH_COMMA_MAP(index, context, map, ...) map(context, index, Combine_ELEMENT_AT(index, __VA_ARGS__))

// rx for

#define Combine_FOR_MAX(max, concat, map, ...) Combine_CAT2(Combine_FOR_, max)(concat, map, ## __VA_ARGS__)

#define Combine_FOR_0(concat, map, ...)
#define Combine_FOR_1(concat, map, ...) map(0, __VA_ARGS__)
#define Combine_FOR_2(concat, map, ...) concat(1, Combine_FOR_1(concat, map, ## __VA_ARGS__), map(1, __VA_ARGS__), __VA_ARGS__)
#define Combine_FOR_3(concat, map, ...) concat(2, Combine_FOR_2(concat, map, ## __VA_ARGS__), map(2, __VA_ARGS__), __VA_ARGS__)
#define Combine_FOR_4(concat, map, ...) concat(3, Combine_FOR_3(concat, map, ## __VA_ARGS__), map(3, __VA_ARGS__), __VA_ARGS__)
#define Combine_FOR_5(concat, map, ...) concat(4, Combine_FOR_4(concat, map, ## __VA_ARGS__), map(4, __VA_ARGS__), __VA_ARGS__)
#define Combine_FOR_6(concat, map, ...) concat(5, Combine_FOR_5(concat, map, ## __VA_ARGS__), map(5, __VA_ARGS__), __VA_ARGS__)

