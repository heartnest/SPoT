//
//  ImageViewController.m
//  Shutterbug
//
//  Created by HeartNest on 2/4/13.
//  Copyright (c) 2013 HeartNest. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()<UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong,nonatomic)UIImageView *imageView;
@end

@implementation ImageViewController

-(void)setImageURL:(NSURL *)imageURL{
    _imageURL = imageURL;
    [self resetImg];
}

-(void)resetImg{
    if(self.scrollView){
        //to default
        self.scrollView.contentSize = CGSizeZero;
        self.imageView.image = nil;
        
        NSData *imageData = [[NSData alloc]initWithContentsOfURL:self.imageURL];
        // UIImage is one of the few UIKit objects which is thread-safe, so we can do this here
        UIImage *image= [[UIImage alloc]initWithData:imageData];
            if (image) {
                self.scrollView.zoomScale=1.0;//important
                self.scrollView.contentSize = image.size;
                self.imageView.image = image;
                self.imageView.frame = CGRectMake(0, 0, image.size.width, image.size.height);
                float xzoom = (self.scrollView.bounds.size.width / self.imageView.image.size.width);
                float yzoom = (self.scrollView.bounds.size.height / self.imageView.image.size.height);
                self.scrollView.zoomScale =
                (xzoom < yzoom) ? xzoom : yzoom;  // smaller zoom to show whole pic with borders
                //(xzoom < yzoom) ? yzoom : xzoom;  // larger zoom to fill screen
            }
    }
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return  self.imageView;
}

-(UIImageView *)imageView{
    if(!_imageView)//CGRectZero origion zero size zero
        _imageView = [[UIImageView alloc]initWithFrame:CGRectZero];
    return  _imageView;
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
    self.scrollView.minimumZoomScale = 0.4;
    self.scrollView.maximumZoomScale = 5.0;
    self.scrollView.delegate = self;
    [self resetImg ];
}

@end
