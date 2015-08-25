//
// PPEmitterView.h
// Created by Particle Playground on 8/23/15
//

#import "PPEmitterView.h"

@implementation PPEmitterView

-(id)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	
	if (self)
    {
		self.backgroundColor = [UIColor clearColor];
	}
	
	return self;
}

+ (Class) layerClass
{
    //configure the UIView to have emitter layer
    return [CAEmitterLayer class];
}

-(void)awakeFromNib
{
    CAEmitterLayer *emitterLayer = (CAEmitterLayer*)self.layer;

	emitterLayer.name = @"emitterLayer";
	emitterLayer.emitterPosition = CGPointMake(69, -100);
	emitterLayer.emitterZPosition = 0;

	emitterLayer.emitterSize = CGSizeMake(50.00, 1.00);
	emitterLayer.emitterDepth = 0.00;

	emitterLayer.emitterShape = kCAEmitterLayerLine;

	emitterLayer.emitterMode = kCAEmitterLayerPoints;

	emitterLayer.renderMode = kCAEmitterLayerOldestLast;

    emitterLayer.shouldRasterize = YES;


	emitterLayer.seed = 2458817236;



	
	// Create the emitter Cell
	CAEmitterCell *emitterCell = [CAEmitterCell emitterCell];
	
	emitterCell.name = @"untitled";
	emitterCell.enabled = YES;

	emitterCell.contents = (id)[[UIImage imageNamed:@"snow3.png"] CGImage];
	emitterCell.contentsRect = CGRectMake(0.00, 0.00, 1.00, 1.00);

	emitterCell.magnificationFilter = kCAFilterLinear;
	emitterCell.minificationFilter = kCAFilterLinear;
	emitterCell.minificationFilterBias = 0.00;

	emitterCell.scale = 0.50;
	emitterCell.scaleRange = 0.40;
	emitterCell.scaleSpeed = 0.13;

	emitterCell.color = [[UIColor colorWithRed:0.24 green:0.52 blue:0.53 alpha:0.21] CGColor];
	emitterCell.redRange = 0.89;
	emitterCell.greenRange = 0.34;
	emitterCell.blueRange = 0.22;
	emitterCell.alphaRange = 1.0;

	emitterCell.redSpeed = 5.00;
	emitterCell.greenSpeed = 5.00;
	emitterCell.blueSpeed = 5.00;
	emitterCell.alphaSpeed = 0.4;

	emitterCell.lifetime = 10.00;
	emitterCell.lifetimeRange = 0.09;
	emitterCell.birthRate = 288;
	emitterCell.velocity = 280.26;
	emitterCell.velocityRange = 202.47;
	emitterCell.xAcceleration = -50.00;
	emitterCell.yAcceleration = 66.00;
	emitterCell.zAcceleration = 25.00;

	// these values are in radians, in the UI they are in degrees
	emitterCell.spin = 12.566;
	emitterCell.spinRange = 12.566;
	emitterCell.emissionLatitude = 0.698;
	emitterCell.emissionLongitude = 0.768;
	emitterCell.emissionRange = 5.934;

	emitterLayer.emitterCells = @[emitterCell];

}

@end
