//
//  UIImageView+ImageContent.m
//  ScanQRcodeDemo
//
//  Created by 党玉华 on 2020/1/9.
//  Copyright © 2020 Linkdom. All rights reserved.
//

#import "UIImageView+ImageContent.h"

@implementation UIImageView (ImageContent)

+ (NSString *)getImageContent:(UIImage *)image{
    NSData *imageData = UIImagePNGRepresentation(image);
    CIImage *ciImage = [CIImage imageWithData:imageData];
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:@{CIDetectorAccuracy: CIDetectorAccuracyLow}];//CIDetectorAccuracyLow精度低，速度快  //精度高，速度慢CIDetectorAccuracyHigh
    NSArray *features = [detector featuresInImage:ciImage];
    NSString *content = @"";
    if (features.count > 0) {
        CIQRCodeFeature *feature = features[0];
        content = feature.messageString;
    }
    return content;
}

@end
