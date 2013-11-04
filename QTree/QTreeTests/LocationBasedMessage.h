//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "QTreeInsertable.h"

@interface LocationBasedMessage : NSObject<QTreeInsertable>

@property(nonatomic, assign) NSString* message;
@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

@end