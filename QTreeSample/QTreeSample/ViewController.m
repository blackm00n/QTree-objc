//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "ViewController.h"
#import "QTree.h"
#import "DummyAnnotation.h"
#import "QCluster.h"
#import "ClusterAnnotationView.h"

static NSInteger kMaxObjectsCount = 1000;

inline static CLLocationCoordinate2D referenceLocation()
{
  return CLLocationCoordinate2DMake(50, 14.42);
}

inline static CLLocationDegrees degreesDispersion()
{
  return 0.5;
}

@interface ViewController()<MKMapViewDelegate>

@property(nonatomic, weak) IBOutlet MKMapView* mapView;
@property(nonatomic, weak) IBOutlet UISegmentedControl* segmentedControl;

@property(nonatomic, strong) QTree* qTree;

@end

@implementation ViewController

-(void)awakeFromNib
{
  [super awakeFromNib];
  self.qTree = [QTree new];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^
  {
    srand48(time(0));
    for( NSUInteger i = 0; i < kMaxObjectsCount; ++i ) {
      DummyAnnotation* object = [DummyAnnotation new];
      object.coordinate = CLLocationCoordinate2DMake(referenceLocation().latitude + degreesDispersion() * (1 - 2 * drand48()),
                                                     referenceLocation().longitude + degreesDispersion() * (1 - 2 * drand48()));
      [self.qTree insertObject:object];
      dispatch_async(dispatch_get_main_queue(), ^
      {
        [self reloadAnnotations];
      });
    }
  });
}

-(void)viewDidLoad
{
  [super viewDidLoad];
  [self.mapView setCenterCoordinate:referenceLocation()];
}

-(void)reloadAnnotations
{
  if( !self.isViewLoaded ) {
    return;
  }

  const MKCoordinateRegion mapRegion = self.mapView.region;
  BOOL useClustering = (self.segmentedControl.selectedSegmentIndex == 0);
  const CLLocationDegrees minNonClusteredSpan = useClustering ? MIN(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5
                                                              : 0;
  NSArray* objects = [self.qTree getObjectsInRegion:mapRegion minNonClusteredSpan:minNonClusteredSpan];

  NSMutableArray* annotationsToRemove = [self.mapView.annotations mutableCopy];
  [annotationsToRemove removeObject:self.mapView.userLocation];
  [annotationsToRemove removeObjectsInArray:objects];
  [self.mapView removeAnnotations:annotationsToRemove];

  NSMutableArray* annotationsToAdd = [objects mutableCopy];
  [annotationsToAdd removeObjectsInArray:self.mapView.annotations];

  [self.mapView addAnnotations:annotationsToAdd];
}

-(IBAction)segmentChanged:(id)sender
{
  [self reloadAnnotations];
}

#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
  [self reloadAnnotations];
}

-(MKAnnotationView*)mapView:(MKMapView*)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
  if( [annotation isKindOfClass:[QCluster class]] ) {
    ClusterAnnotationView* annotationView = (ClusterAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:[ClusterAnnotationView reuseId]];
    if( !annotationView ) {
      annotationView = [[ClusterAnnotationView alloc] initWithCluster:(QCluster*)annotation];
    }
    annotationView.cluster = (QCluster*)annotation;
    return annotationView;
  } else {
    return nil;
  }
}

-(void)mapView:(MKMapView*)mapView didSelectAnnotationView:(MKAnnotationView*)view
{
  id<MKAnnotation> annotation = view.annotation;
  if( [annotation isKindOfClass:[QCluster class]] ) {
    QCluster* cluster = (QCluster*)annotation;
    [mapView setRegion:MKCoordinateRegionMake(cluster.coordinate, MKCoordinateSpanMake(2.5 * cluster.radius, 2.5 * cluster.radius))
              animated:YES];
  } else {
    [self.qTree removeObject:(id<QTreeInsertable>)annotation];
    [self reloadAnnotations];
  }
}

@end