//
// This file is subject to the terms and conditions defined in
// file 'LICENSE.md', which is part of this source code package.
//

#import "ClusterAnnotationView.h"
#import "QCluster.h"

@implementation ClusterAnnotationView

+(NSString*)reuseId
{
  return NSStringFromClass(self);
}

+(NSDictionary*)textAttributes
{
  NSMutableParagraphStyle* paragraphStyle = [[NSMutableParagraphStyle alloc] init];
  paragraphStyle.alignment = NSTextAlignmentCenter;
  return @{NSParagraphStyleAttributeName : paragraphStyle,
          NSForegroundColorAttributeName : [UIColor whiteColor],
                     NSFontAttributeName : [UIFont boldSystemFontOfSize:12]};
}

+(CGRect)boundsForCluster:(QCluster*)cluster
{
  const CGSize textSize = [[@(cluster.objectsCount) stringValue] sizeWithAttributes:[self textAttributes]];
  const CGFloat side = ceilf(MAX(textSize.height, textSize.width)) + 10;
  return CGRectMake(0, 0, side, side);
}


-(instancetype)initWithCluster:(QCluster*)cluster
{
  self = [super initWithAnnotation:(id<MKAnnotation>)cluster reuseIdentifier:[[self class] reuseId]];
  if( !self ) {
    return nil;
  }
  self.opaque = NO;
  self.backgroundColor = [UIColor clearColor];
  return self;
}

-(void)setCluster:(QCluster*)cluster
{
  _cluster = cluster;
  self.annotation = (id<MKAnnotation>)cluster;
  self.bounds = [[self class] boundsForCluster:cluster];
  [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
  CGContextRef context = UIGraphicsGetCurrentContext();
  CGContextSetAllowsAntialiasing(context, true);

  [[UIColor whiteColor] setFill];
  const CGRect outerRect = CGRectInset(rect, 1, 1);
  CGContextFillEllipseInRect(context, outerRect);

  [[UIColor colorWithRed:0 green:122/255. blue:1 alpha:1] setFill];
  const CGRect innerRect = CGRectInset(rect, 3, 3);
  CGContextFillEllipseInRect(context, innerRect);

  [[UIColor lightGrayColor] setStroke];
  CGContextSetLineWidth(context, 1);
  CGContextStrokeEllipseInRect(context, outerRect);
  CGContextStrokeEllipseInRect(context, innerRect);

  NSString* text = [@(self.cluster.objectsCount) stringValue];
  NSDictionary* attributes = [[self class] textAttributes];
  const CGSize textSize = [text sizeWithAttributes:attributes];
  CGRect textRect = CGRectInset(rect, 5, 5);
  textRect.origin.y = rect.origin.y + (rect.size.height - textSize.height) / 2;
  textRect.size.height = textSize.height;
  [text drawInRect:textRect withAttributes:attributes];
}

@end