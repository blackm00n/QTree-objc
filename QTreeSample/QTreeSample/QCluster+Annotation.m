//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "QCluster+Annotation.h"

@implementation QCluster(Annotation)

-(NSString*)title
{
  return @"Cluster";
}

-(NSString*)subtitle
{
  return [NSString stringWithFormat:@"%d objects here", self.objectsCount];
}

@end