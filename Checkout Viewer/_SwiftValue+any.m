//
//  _SwiftValue+_SwiftValue.m
//  Checkout Viewer
//
//  Created by Brent Royal-Gordon on 11/18/17.
//  Copyright © 2017 Architechies. All rights reserved.
//

#import "_SwiftValue+any.h"

// This is part of the Swift runtime.
__attribute__((swiftcall))
void _swift_bridgeNonVerbatimBoxedValue(const void *sourceValue,
                                   void *destValue,
                                   const void *nativeType);

// This is part of the Swift runtime.
@interface _SwiftValue: NSObject

- (const void *)_swiftTypeMetadata;
- (const void *)_swiftValue;

@end

void getAny(_SwiftValue * value, void * existential) {
    const void * sourceValue = [value _swiftValue];
    const void * type = [value _swiftTypeMetadata];
    _swift_bridgeNonVerbatimBoxedValue(sourceValue, existential, type);
}

