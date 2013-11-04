//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

@import MapKit;

#import "QTreeInsertable.h"

@interface DummyAnnotation : NSObject<MKAnnotation, QTreeInsertable>

@property(nonatomic, assign) CLLocationCoordinate2D coordinate;

-(NSString*)title;

@end