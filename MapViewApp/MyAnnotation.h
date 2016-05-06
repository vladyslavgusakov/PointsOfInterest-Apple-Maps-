//
//  MyAnnotation.h
//  MapViewApp
//
//  Created by Vladyslav Gusakov on 3/18/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface MyAnnotation : MKPointAnnotation

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *subTitle;
@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) UIImage *image;


@end
