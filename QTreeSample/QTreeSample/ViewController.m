//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "ViewController.h"
#import "QTree.h"
#import "DummyAnnotation.h"

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
    for( NSUInteger i = 0; i < 1000; ++i ) {
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
  [self.mapView removeAnnotations:self.mapView.annotations];
  const MKCoordinateRegion mapRegion = self.mapView.region;
  const CLLocationDegrees minNonClusteredSpan = MIN(mapRegion.span.latitudeDelta, mapRegion.span.longitudeDelta) / 5;
  NSArray* objects = [self.qTree getObjectsInRegion:mapRegion minNonClusteredSpan:minNonClusteredSpan];
  [self.mapView addAnnotations:objects];
}

-(IBAction)segmentChanged:(id)sender
{
  if( self.segmentedControl.selectedSegmentIndex == 0 ) {

  } else {

  }
}

#pragma mark MKMapViewDelegate

-(void)mapView:(MKMapView*)mapView regionDidChangeAnimated:(BOOL)animated
{
  [self reloadAnnotations];
}

@end