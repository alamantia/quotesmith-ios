//
//  HistoryTableViewCell.m
//  QuoteSmith
//
//  Created by waffles on 6/27/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "HistoryTableViewCell.h"
#import "AppContext.h"

#define PADDING 20.0

@implementation HistoryTableViewCell

+ (CGFloat) heightForQuote : (NSDictionary *) quote inFrame:(CGRect) frame
{
    CGSize max = CGSizeMake(frame.size.width - (PADDING * 2), 9999999);
    
    CGRect quoteLabelRect = [quote[@"quote"] boundingRectWithSize:CGSizeMake(frame.size.width - (PADDING * 4), 9999999) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[[AppContext sharedContext] fontForType:FONT_TYPE_HISTORY_QUOTE]} context:nil];

    CGRect authorLabelRect = [quote[@"author"] boundingRectWithSize:max options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[[AppContext sharedContext] fontForType:FONT_TYPE_HISTORY_AUTOR]} context:nil];

    return authorLabelRect.size.height + quoteLabelRect.size.height + (PADDING * 4);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void) layoutSubviews {
    [super layoutSubviews];
    self.authorLabel.font = [[AppContext sharedContext] fontForType:FONT_TYPE_HISTORY_AUTOR];
    self.quoteLabel.font  = [[AppContext sharedContext] fontForType:FONT_TYPE_HISTORY_QUOTE];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
