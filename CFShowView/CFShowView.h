//
//  CFShowView.h
//  TestForShowView
//
//  Created by  chenfei on 15/12/6.
//  Copyright © 2015年 chenfei. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CFShowView;
@class ASIHTTPRequest;

@protocol CFShowViewDelegate <NSObject>

@required
//拼接URLString
-(NSString *)URLStringForSearchAppendingTextFieldText:(UITextField *)textField;
//控件实现网络请求，返回的数据通过代理传给调用者，再回传数组给控件来显示数据
-(NSMutableArray *)CFShowView:(CFShowView *)showView arrayFromResponse:(NSData *)data;
@optional
//点击cell的回调方法,如果没有点击，selected为NO，index为100
-(void)CFShowView:(CFShowView *)showView SelectedRowAtIndexPath:(NSInteger)index andReturnTheData:(NSMutableArray *)dataArray didSelected:(BOOL)selected;
@end

@interface CFShowView : UIView<CFShowViewDelegate>

@property(nonatomic,strong)id<CFShowViewDelegate> delegate;

-(instancetype)init;
-(void)show;


@end
