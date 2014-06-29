//
//  HistoryTableViewCell.h
//  QuoteSmith
//
//  Created by waffles on 6/27/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewCell : UITableViewCell

@property  IBOutlet UILabel *authorLabel;
@property  IBOutlet UILabel *quoteLabel;

+ (CGFloat) heightForQuote : (NSDictionary *) quote inFrame:(CGRect) frame;

@end
