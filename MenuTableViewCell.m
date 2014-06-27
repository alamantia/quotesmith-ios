//
//  MenuTableViewCell.m
//  QuoteSmith
//
//  Created by waffles on 6/26/14.
//  Copyright (c) 2014 Anthony LaMantia. All rights reserved.
//

#import "MenuTableViewCell.h"

@interface MenuTableViewCell () {
    UIView  *borderView;
    UILabel *titleLabel;
}
@end
@implementation MenuTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:21];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self.contentView addSubview:titleLabel];
    }
    return self;
}

- (void) setTitle : (NSString *) title
{
    titleLabel.text = title;
    return;
}

- (void)awakeFromNib
{

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

- (void) layoutSubviews
{
    
    CGRect titleLabelRect = [titleLabel.text boundingRectWithSize: CGSizeMake(99999,
                                                                              99999)
                                                          options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:titleLabel.font} context:nil];
    titleLabel.frame = CGRectMake(self.frame.size.width/2 - titleLabelRect.size.width/2,
                                  self.frame.size.height/2 - titleLabelRect.size.height/2,
                                  titleLabelRect.size.width,
                                  titleLabelRect.size.height);
}

@end
