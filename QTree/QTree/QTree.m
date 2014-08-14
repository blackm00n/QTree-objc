//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "QTree.h"
#import "QNode.h"
#import "QTreeGeometryUtils.h"

@interface QTree()

@property(nonatomic, strong) QNode* rootNode;

@end

@implementation QTree

-(id)init
{
	self = [super init];
	if( !self ) {
    return nil;
  }
	[self cleanup];
	return self;
}

- (void) cleanup
{
    self.rootNode = [[QNode alloc] initWithRegion:MKCoordinateRegionForMapRect(MKMapRectWorld)];
}

-(void)insertObject:(id<QTreeInsertable>)insertableObject
{
  [self.rootNode insertObject:insertableObject];
}

-(void)removeObject:(id<QTreeInsertable>)insertableObject
{
  [self.rootNode removeObject:insertableObject];
}

-(NSUInteger)count
{
  return self.rootNode.count;
}

-(NSArray*)getObjectsInRegion:(MKCoordinateRegion)region minNonClusteredSpan:(CLLocationDegrees)span
{
	return [self.rootNode getObjectsInRegion:region minNonClusteredSpan:span];
}

-(NSArray*)neighboursForLocation:(CLLocationCoordinate2D)location limitCount:(NSUInteger)limit
{
  NSArray* nodesPath = [self nodesPathForLocation:location];
  for( QNode* node in nodesPath.reverseObjectEnumerator ) {
    if( node.count < limit && node != [nodesPath firstObject] ) {
      continue;
    }
    MKCoordinateRegion region;
    if( node == self.rootNode ) {
      region = node.region;
    } else {
      const CLLocationDegrees latitudeDelta = 2 * (node.region.span.latitudeDelta / 2 - fabs(node.region.center.latitude - location.latitude));
      const CLLocationDegrees longitudeDelta = 2 * (node.region.span.longitudeDelta / 2 - fabs(node.region.center.longitude - location.longitude));
      const CLLocationDegrees delta = MIN(latitudeDelta, longitudeDelta);
      region = MKCoordinateRegionMake(location, MKCoordinateSpanMake(delta, delta));
    }
    NSMutableArray* objects = [[self getObjectsInRegion:region minNonClusteredSpan:0] mutableCopy];
    if( objects.count < limit && node != [nodesPath firstObject] ) {
      continue;
    }
    [objects sortUsingComparator:^NSComparisonResult(id<QTreeInsertable> obj1, id<QTreeInsertable> obj2)
    {
      CLLocationDistance m1 = CLMetersBetweenCoordinates(obj1.coordinate, location);
      CLLocationDistance m2 = CLMetersBetweenCoordinates(obj2.coordinate, location);
      if( m1 < m2 ) {
        return NSOrderedAscending;
      } else if( m1 > m2 ) {
        return NSOrderedDescending;
      } else {
        return NSOrderedSame;
      }
    }];
    return [objects subarrayWithRange:NSMakeRange(0, MIN(limit, objects.count))];
  }
  return @[];
}

-(NSArray*)nodesPathForLocation:(CLLocationCoordinate2D)location
{
  if( !MKCoordinateRegionContainsCoordinate(self.rootNode.region, location) ) {
    return @[];
  }
  QNode* cur = self.rootNode;
  NSMutableArray* result = [NSMutableArray array];
  while( cur ) {
    [result addObject:cur];
    cur = [cur childNodeForLocation:location];
  }
  return result;
}

@end
