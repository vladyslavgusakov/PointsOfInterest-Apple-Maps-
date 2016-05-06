//
//  ViewController.m
//  MapViewApp
//
//  Created by Vladyslav Gusakov on 3/16/16.
//  Copyright © 2016 Vladyslav Gusakov. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <UISearchDisplayDelegate, UISearchBarDelegate>
{
    BOOL gotLocation;
}

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property(nonatomic,strong) CLLocationManager *locationManager;
@property (strong, nonatomic) IBOutlet UIButton *doneButton;
- (IBAction)doneClicked:(id)sender;

- (IBAction)setMap:(UISegmentedControl *)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.searchBar.delegate = self;
    
    gotLocation = false;
    self.doneButton.hidden = YES;
    
    self.locationManager = [[CLLocationManager alloc]init];
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    
    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    // Place a TurnToTech pin
    MyAnnotation *annotation = [[MyAnnotation alloc] init];
    [annotation setCoordinate:CLLocationCoordinate2DMake(40.741434,-73.990039)];
    [annotation setTitle:@"TurnToTech"]; //You can set the subtitle too
    [annotation setSubtitle:@"184 5th Ave, New York, NY 10010"];
    [annotation setUrl:[NSURL URLWithString:@"http://turntotech.io"]];
    [annotation setImage:[UIImage imageNamed:@"ttt"]];
    
    [self.mapView addAnnotation:annotation];
    
    
    // zoom in on that pin when app loads
//    MKMapRect zoomRect = MKMapRectNull;
//    for (id <MKAnnotation> annotation in self.mapView.annotations)
//    {
        MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
        MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
//    }
    [self.mapView setVisibleMapRect:pointRect animated:YES];
    
    
    // Place a outbackRestaurant pin
    MyAnnotation *outbackRestaurant = [[MyAnnotation alloc] init];
    [outbackRestaurant setCoordinate:CLLocationCoordinate2DMake(40.742290, -73.992047)];
    [outbackRestaurant setTitle:@"Outback Steakhouse"];
    [outbackRestaurant setSubtitle:@"60 W 23rd St, New York, NY 10010"];
    [outbackRestaurant setUrl:[NSURL URLWithString:@"https://www.outback.com"]];
    [outbackRestaurant setImage:[UIImage imageNamed:@"outback"]];
    [self.mapView addAnnotation:outbackRestaurant];
    
    // Place a oliveGarden pin
    MyAnnotation *oliveGarden = [[MyAnnotation alloc] init];
    [oliveGarden setCoordinate:CLLocationCoordinate2DMake(40.742269, -73.992938)];
    [oliveGarden setTitle:@"Olive Garden"];
    [oliveGarden setSubtitle:@"696 Ave of the Americas, New York, NY 10010"];
    [oliveGarden setUrl:[NSURL URLWithString:@"http://www.olivegarden.com"]];
    [oliveGarden setImage:[UIImage imageNamed:@"olive"]];
    [self.mapView addAnnotation:oliveGarden];
    
    
    
}

-(void) createPlaceMark: (MKMapItem *) mkItem  {
    
    MyAnnotation *newPoint = [[MyAnnotation alloc] init];
    [newPoint setCoordinate:CLLocationCoordinate2DMake(mkItem.placemark.coordinate.latitude, mkItem.placemark.coordinate.longitude)];
    [newPoint setTitle:mkItem.name];
    [newPoint setUrl:mkItem.url];
    
    
//    [newPoint setSubtitle:mkItem.placemark.addressDictionary[@"FormattedAddressLines"]];
    [self.mapView addAnnotation:newPoint];
}

-(NSURL *) convertedURL: (NSURL *) url {
    NSString *newURLString = [url absoluteString];
    
    newURLString = [newURLString stringByReplacingOccurrencesOfString:@"http://" withString:@""];
    newURLString = [newURLString stringByReplacingOccurrencesOfString:@"https://" withString:@""];
    NSURL *newURL = [NSURL URLWithString:newURLString];
    
    return newURL;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
//    NSLog(@"Location: %f, %f",
//          userLocation.location.coordinate.latitude,
//          userLocation.location.coordinate.longitude);
    
    if (gotLocation == false) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(userLocation.location.coordinate, 250, 250);
        [self.mapView setRegion:region animated:YES];
        gotLocation = true;
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MyAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
            pinView.calloutOffset = CGPointMake(0, 32);
            
//            // Add a detail disclosure button to the callout.
            UIButton* rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            // Add an image to the left callout.
            UIImageView *iconView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, pinView.bounds.size.height, pinView.bounds.size.height)];
            iconView.image = ((MyAnnotation*)annotation).image;
            
            pinView.leftCalloutAccessoryView = iconView;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

-(void) mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    MyAnnotation *pin = (MyAnnotation *) [view annotation];
    
    if (!pin.image) {
        NSString *imageStr = [[self convertedURL:pin.url] absoluteString];
        NSURL *imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/s2/favicons?domain_url=%@",imageStr]];
        NSData *imageData = [NSData dataWithContentsOfURL:imageURL];
        view.leftCalloutAccessoryView =  [[UIImageView alloc] initWithImage:[UIImage imageWithData:imageData]];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSLog(@"%@",view.annotation.title);
    
    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width*0.2, self.view.bounds.size.height*0.2, self.view.bounds.size.width*0.6, self.view.bounds.size.height*0.6)];
//    [webViewController.view addSubview:webView];
    
    NSURLRequest *requestURL = [NSURLRequest requestWithURL:((MyAnnotation*)view.annotation).url];
    
    [webView loadRequest:requestURL];
    [self.view addSubview:webView];
    self.doneButton.hidden = NO;
    
//    [self performSegueWithIdentifier:@"DetailsIphone" sender:view];
}

- (IBAction)doneClicked:(id)sender {
    for (UIView *tmp in self.view.subviews) {
        if ([tmp isKindOfClass:UIWebView.class]) {
            [tmp removeFromSuperview];
        }
    }
    
    self.doneButton.hidden = YES;
}

- (IBAction)setMap:(UISegmentedControl *)sender {
    
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.mapView.mapType = MKMapTypeStandard;
            break;
        case 1:
            self.mapView.mapType = MKMapTypeHybrid;
            break;
        case 2:
            self.mapView.mapType = MKMapTypeSatellite;
            break;
        default:
            break;
    }
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self.searchBar resignFirstResponder];
    [self textRequest];
}

-(void) textRequest {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = self.searchBar.text;
    request.region = self.mapView.region;
    
    MKLocalSearch *localSearch = [[MKLocalSearch alloc] initWithRequest:request];
    
    __block  MKLocalSearchResponse *results;
    
    [localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error){
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
        
        results = response;
        
        NSLog(@"results: %@", results);
        
        for (MKMapItem *item in results.mapItems) {
            [self createPlaceMark:item];
        }
    }];

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    self.doneButton.hidden = YES;
    for (UIView *tmp in self.view.subviews) {
        if ([tmp isKindOfClass:UIWebView.class]) {
            [tmp removeFromSuperview];
        }
    }
    [super touchesBegan:touches withEvent:event];
}

@end
