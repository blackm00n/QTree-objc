//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

@import XCTest;

#import "QTree.h"
#import "LocationBasedMessage.h"
#import "QNode.h"

@interface QTreeTests : XCTestCase

@property(nonatomic, strong) QTree* tree;

@end

@implementation QTreeTests

+(CLLocationCoordinate2D)tallinLocation
{
  return CLLocationCoordinate2DMake(59.43, 24.75);
}

+(CLLocationCoordinate2D)gainesvilleLocation
{
  return CLLocationCoordinate2DMake(29.651997, 82.324992);
}

+(LocationBasedMessage*)moscowBasedMessage
{
  const CLLocationCoordinate2D moscowLocation = CLLocationCoordinate2DMake(57.75, 37.62);
  LocationBasedMessage* msg = [LocationBasedMessage new];
  msg.message = @"Hello Moscow!";
  msg.coordinate = moscowLocation;
  return msg;
}

+(LocationBasedMessage*)stPetersburgBasedMessage
{
  const CLLocationCoordinate2D stPetersburgLocation = CLLocationCoordinate2DMake(59.95, 30.32);
  LocationBasedMessage* msg = [LocationBasedMessage new];
  msg.message = @"Hi St. Petersburg!";
  msg.coordinate = stPetersburgLocation;
  return msg;
}


-(void)setUp
{
  [super setUp];
  self.tree = [QTree new];
}

-(void)tearDown
{
  [super tearDown];
}

-(void)testSameObjects
{
  LocationBasedMessage* moscowBasedMessage = [QTreeTests moscowBasedMessage];
  [self.tree insertObject:moscowBasedMessage];

  LocationBasedMessage* stPetersburgBasedMessage = [QTreeTests stPetersburgBasedMessage];
  [self.tree insertObject:stPetersburgBasedMessage];

  [self.tree insertObject:moscowBasedMessage];

  XCTAssertEqual(self.tree.count, 2, @"Tree should contain only 2 objects");
}

-(void)testSatellites
{
  [self.tree insertObject:[QTreeTests moscowBasedMessage]];
  [self.tree insertObject:[QTreeTests stPetersburgBasedMessage]];
  [self.tree insertObject:[QTreeTests moscowBasedMessage]];

  XCTAssertEqual(self.tree.count, 3, @"Tree should contain 3 objects");
}

-(void)testNeighbors
{
  const CLLocationCoordinate2D tallinLocation = [QTreeTests tallinLocation];

  LocationBasedMessage* moscowBasedMessage = [QTreeTests moscowBasedMessage];
  [self.tree insertObject:moscowBasedMessage];

  {
    NSArray* neighbors = [self.tree neighboursForLocation:tallinLocation limitCount:2];
    XCTAssertEqual(neighbors.count, 1, @"Should find only 1 object nearby");
  }

  LocationBasedMessage* stPetersburgBasedMessage = [QTreeTests stPetersburgBasedMessage];
  [self.tree insertObject:stPetersburgBasedMessage];

  {
    NSArray* neighbors = [self.tree neighboursForLocation:tallinLocation limitCount:2];
    XCTAssertEqual(neighbors.count, 2, @"Should find 2 objects");
    XCTAssert([neighbors firstObject] == stPetersburgBasedMessage, @"Message near St. Petersburg should be the first neighbour");
    XCTAssert([neighbors lastObject] == moscowBasedMessage, @"Message near Moscow should be the second and the last neighbour");
  }
  {
    NSArray* neighbors = [self.tree neighboursForLocation:tallinLocation limitCount:1];
    XCTAssertEqual(neighbors.count, 1, @"Should find only one object nearby");
    XCTAssertEqual([neighbors firstObject], stPetersburgBasedMessage, @"Message near St. Petersburg should be the first neighbour");
  }
}

-(void)testFetching
{
  [self.tree insertObject:[QTreeTests moscowBasedMessage]];
  LocationBasedMessage* stPetersburgBasedMessage = [QTreeTests stPetersburgBasedMessage];
  [self.tree insertObject:stPetersburgBasedMessage];

  {
    NSArray* objectsInRegion = [self.tree getObjectsInRegion:MKCoordinateRegionMake([QTreeTests tallinLocation], MKCoordinateSpanMake(12, 12))
                                         minNonClusteredSpan:0];
    XCTAssertEqual(objectsInRegion.count, 1, @"Should fetch only one object");
    XCTAssert([objectsInRegion firstObject] == stPetersburgBasedMessage, @"Message near St. Petersburg should be found");
  }
  {
    NSArray* objectsInRegion = [self.tree getObjectsInRegion:MKCoordinateRegionMake([QTreeTests tallinLocation], MKCoordinateSpanMake(10, 10))
                                         minNonClusteredSpan:0];
    XCTAssertEqual(objectsInRegion.count, 0, @"Should not fetch any object");
  }
}

-(void)testRemoval
{
  LocationBasedMessage* moscowBasedMessage = [QTreeTests moscowBasedMessage];
  [self.tree insertObject:moscowBasedMessage];
  LocationBasedMessage* stPetersburgBasedMessage = [QTreeTests stPetersburgBasedMessage];
  [self.tree insertObject:stPetersburgBasedMessage];
  [self.tree removeObject:stPetersburgBasedMessage];
  NSArray* allObjects = [self.tree getObjectsInRegion:MKCoordinateRegionForMapRect(MKMapRectWorld) minNonClusteredSpan:0];
  XCTAssertEqual(allObjects.count, 1, @"Should contain only one object");
  XCTAssertEqual(allObjects[0], moscowBasedMessage, @"Object should be left");
}

-(void)testFarAwayFetch
{
  LocationBasedMessage* msg = [LocationBasedMessage new];
  msg.message = @"reported by andjash";
  msg.coordinate = CLLocationCoordinate2DMake(34.055938, -118.248386);
  [self.tree insertObject:msg];
  NSArray* fetchResult = [self.tree neighboursForLocation:CLLocationCoordinate2DMake(55.801854, 37.508097) limitCount:NSUIntegerMax];
  XCTAssertEqual(fetchResult.count, 1, @"Number of fetched objects should be 1, but is %@", @(fetchResult.count));
}

-(void)testSameLocationCluster
{
  LocationBasedMessage* msg = [LocationBasedMessage new];
  msg.message = @"pull request #6 by salagadoola";
  msg.coordinate = [QTreeTests gainesvilleLocation];

  LocationBasedMessage* msg2 = [LocationBasedMessage new];
  msg2.message = @"Gainesville";
  msg2.coordinate = [QTreeTests gainesvilleLocation];

  LocationBasedMessage* msg3 = [LocationBasedMessage new];
  msg3.message = @"UF";
  msg3.coordinate = [QTreeTests gainesvilleLocation];

  [self.tree insertObject:msg];

  MKCoordinateRegion const region = MKCoordinateRegionMake([QTreeTests gainesvilleLocation], MKCoordinateSpanMake(1, 1));

  NSArray* objectsInRegion = [self.tree getObjectsInRegion:region minNonClusteredSpan:0.01];
  XCTAssert([[objectsInRegion firstObject] isKindOfClass:[LocationBasedMessage class]], @"When span is non-zero but only one object is in region that object should be returned, not cluster");

  [self.tree insertObject:msg2];
  [self.tree insertObject:msg3];

  NSArray* objectsInRegionZeroSpan = [self.tree getObjectsInRegion:region minNonClusteredSpan:0];
  XCTAssertEqual(objectsInRegionZeroSpan.count, 3, @"When span is 0 no clusters should be returned, but all 3 objects");

  NSArray* objectsInRegionNonZeroSpan = [self.tree getObjectsInRegion:region minNonClusteredSpan:0.01];
  XCTAssert(objectsInRegionNonZeroSpan.count == 1
      && [objectsInRegionNonZeroSpan[0] isKindOfClass:[QCluster class]], @"When span is non-zero just one cluster should be returned");
}

- (void)testFetchClustersWithObjects
{
  LocationBasedMessage* msg = [LocationBasedMessage new];
  msg.message = @"issue #7";
  msg.coordinate = [QTreeTests gainesvilleLocation];

  LocationBasedMessage* msg2 = [LocationBasedMessage new];
  msg2.message = @"near Gainesville";
  msg2.coordinate = [QTreeTests gainesvilleLocation];

  LocationBasedMessage* msg3 = [LocationBasedMessage new];
  msg3.message = @"near Gainesville 2";
  msg3.coordinate = [QTreeTests gainesvilleLocation];

  [self.tree insertObject:msg];
  [self.tree insertObject:msg2];
  [self.tree insertObject:msg3];

  MKCoordinateRegion const region = MKCoordinateRegionMake([QTreeTests gainesvilleLocation], MKCoordinateSpanMake(1, 1));

  NSArray* objectsInRegion = [self.tree getObjectsInRegion:region minNonClusteredSpan:0.01 fillClusters:YES];
  XCTAssert(objectsInRegion.count == 1 && [objectsInRegion[0] isKindOfClass:[QCluster class]], @"Should get only 1 cluster");
  XCTAssert([objectsInRegion[0] objects].count == 3
      && [[objectsInRegion[0] objects] containsObject:msg]
      && [[objectsInRegion[0] objects] containsObject:msg2]
      && [[objectsInRegion[0] objects] containsObject:msg3], @"All 3 objects should be included in cluster");
  
}

@end
