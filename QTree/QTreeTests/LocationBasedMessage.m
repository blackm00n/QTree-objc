//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "LocationBasedMessage.h"

@implementation LocationBasedMessage

- (NSString*)description
{
    return [NSString stringWithFormat:@"%@ %p: {\n  message: %@\n  location: (%@, %@)\n}", NSStringFromClass([self class]), (__bridge void*)self, self.message, @(self.coordinate.latitude), @(self.coordinate.longitude)];
}

@end