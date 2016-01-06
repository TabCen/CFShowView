//
//  CFShowView.m
//  TestForShowView
//
//  Created by  chenfei on 15/12/6.
//  Copyright © 2015年 chenfei. All rights reserved.
//

#import "CFShowView.h"
#import "CFShowViewCell.h"
#import "ASIHTTPRequest.h"

#define kDEVICE_WIDTH [UIScreen mainScreen].bounds.size.width
#define kDEVICE_HEIGHT [UIScreen mainScreen].bounds.size.height

#define TABLEBGVIEW_HEIGHT _tableBgView.bounds.size.height
#define TABLEBGVIEW_WIDTH  _tableBgView.bounds.size.width

@interface CFShowView ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>{
    NSInteger selfIndex;
}

//@property(nonatomic,strong)UIControl *bgControl;
@property(nonatomic,strong)UIControl*                bgControl;         //黑幕背景
@property(nonatomic,strong)UIView*                   tableBgView;       //窗口背景
@property(nonatomic,strong)UITableView*              tableView;         //选择tableview
@property(nonatomic,strong)UIView *                  titleView;         //头部（包含textField，label，activityView）
@property(nonatomic,strong)UITextField*              textField;         //输入框（包含右边）
@property(nonatomic,strong)UIActivityIndicatorView*  activityView;      //菊花
@property(nonatomic,strong)UIButton*                 insureBtn;         //确定按钮
@property(nonatomic,strong)UIButton*                 cancleBtn;         //取消按钮
@property(nonatomic,strong)NSMutableArray*           array;             //tableview的数据数组

@property(nonatomic,strong)ASIHTTPRequest*           request;           //网络请求
@property(nonatomic,strong)NSURL*                   requestURL;                       //URL
@property(nonatomic,strong)NSString*                urlString;          //

@property(nonatomic)BOOL                            isSelected;         //判断cell是否被选择

//@property(nonatomic)NSInteger selfIndex;

//创建UI的方法将其设置为私有方法

-(void)defalutInit;

@end

@implementation CFShowView

//初始化方法
-(instancetype)init{
    self=[super init];
    if (self) {
        [self defalutInit];
    }
    return self;
}

#pragma mark -UI

-(void)defalutInit{
    //添加背景control
    self.bgControl = [[UIControl alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _bgControl.backgroundColor = [UIColor colorWithRed:.0 green:.0 blue:.0 alpha:.8];
    [_bgControl addTarget:self
                   action:@selector(bgTouched)
         forControlEvents:UIControlEventTouchUpInside];
    //table背景
    self.tableBgView=[[UIView alloc] initWithFrame:CGRectMake(25, 100,kDEVICE_WIDTH-50,150)];
    
    _tableBgView.layer.cornerRadius=5;
    _tableBgView.clipsToBounds=YES;
    _tableBgView.backgroundColor=[UIColor colorWithRed:205/255.0f green:205/255.0f blue:205/255.0f alpha:1];
    
    //添加tableview的内容
    [self createTable];
    
}
-(void)bgTouched{
    [self.textField resignFirstResponder];

}

-(void)createTable{
    //标题部分（包含label、textfield、activity）
    [self addTitleView];
    //身体部分（包含一个tableview）
    [self addBody];
    //脚部（包含一个button）
    [self addFoot];
}

-(void)addTitleView{
    
    self.titleView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, TABLEBGVIEW_WIDTH, 100)];
    _titleView.backgroundColor=[UIColor colorWithRed:239/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    
    UILabel *titleLabel=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, TABLEBGVIEW_WIDTH, 40)];
    titleLabel.textAlignment=NSTextAlignmentCenter;
    titleLabel.text=@"查询";
    titleLabel.textColor=[UIColor blackColor];
    [_titleView addSubview:titleLabel];
    
    self.textField=[[UITextField alloc]initWithFrame:CGRectMake(20, 45, TABLEBGVIEW_WIDTH-40, 35)];
    _textField.backgroundColor=[UIColor whiteColor];
    _textField.borderStyle=UITextBorderStyleRoundedRect;
    _textField.keyboardType=UIKeyboardTypeNumberPad;
    _textField.placeholder=@"请输入手机号或者工号";
    
    //添加右边的放大境button
    UIButton *rbtn=[[UIButton alloc]initWithFrame:CGRectMake(0, 0, 20, 20)];
    [rbtn setImage:[UIImage imageNamed:@"searchbg.png"] forState:UIControlStateNormal];
    [rbtn addTarget:self action:@selector(searchButtonDidClicked) forControlEvents:UIControlEventTouchUpInside];
    _textField.rightView=rbtn;
//    [_textField rightViewRectForBounds:CGRectMake(10,0 , 20, 20)];
//    _textField.rightView
    _textField.rightViewMode=UITextFieldViewModeAlways;
    _textField.delegate=self;

//    UIEdgeInsetsMake
    
    [_titleView addSubview:_textField];
    
    //添加一个UIActiviey
    self.activityView=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityView.center=CGPointMake(_tableBgView.bounds.size.width/2, 90);
    _activityView.color=[UIColor blackColor];

    
    [_titleView addSubview:_activityView];
    
    [self.tableBgView addSubview:_titleView];
    
}

-(void)addBody{
    //创建tableview
    self.tableView=[[UITableView alloc]
                    initWithFrame:CGRectMake(0, _titleView.bounds.size.height,TABLEBGVIEW_WIDTH,0)
                    style:UITableViewStylePlain];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    _tableView.backgroundColor=[UIColor colorWithRed:239/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    _tableView.separatorInset=UIEdgeInsetsZero;
    [self.tableBgView addSubview:_tableView];
    
}
-(void)addFoot{
    ///在添加一个确定按钮
    self.insureBtn=[[UIButton alloc]initWithFrame:CGRectMake(_titleView.bounds.size.width/2.0f, _titleView.bounds.size.height+_tableView.bounds.size.height+1, TABLEBGVIEW_WIDTH/2.0f , 49)];
    _insureBtn.backgroundColor=[UIColor colorWithRed:239/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    [_insureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [_insureBtn setTitleColor:[UIColor colorWithRed:44/255.0f green:127/255.0f blue:253/255.0f alpha:1] forState:UIControlStateNormal];
    [_insureBtn setTitleColor:[UIColor colorWithRed:20/255.0f green:100/255.0f blue:200/255.0f alpha:1] forState:UIControlStateHighlighted];
    [_insureBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
    _insureBtn.tag=1001;
    _insureBtn.enabled=NO;
    [_insureBtn setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];
    
    
    [self.tableBgView addSubview:_insureBtn];
    
    ///添加一个取消按钮
    self.cancleBtn=[[UIButton alloc]initWithFrame:CGRectMake(0, _titleView.bounds.size.height+_tableView.bounds.size.height+1, TABLEBGVIEW_WIDTH , 49)];
    _cancleBtn.backgroundColor=[UIColor colorWithRed:239/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    [_cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [_cancleBtn setTitleColor:[UIColor colorWithRed:44/255.0f green:127/255.0f blue:253/255.0f alpha:1] forState:UIControlStateNormal];
    [_cancleBtn setTitleColor:[UIColor colorWithRed:20/255.0f green:100/255.0f blue:200/255.0f alpha:1] forState:UIControlStateHighlighted];
    [_cancleBtn addTarget:self action:@selector(btnTouched:) forControlEvents:UIControlEventTouchUpInside];
    _cancleBtn.tag=1002;
    [self.tableBgView addSubview:_cancleBtn];
}

-(void)btnTouched:(UIButton *)button{
    
    switch (button.tag) {
        case 1001:{
            //点击确定后判断是否选择了任何cell
            if (!_isSelected) {
                selfIndex=100;
            }
            
            if ([_delegate respondsToSelector:@selector(CFShowView:SelectedRowAtIndexPath:andReturnTheData:didSelected:)]) {
                [_delegate CFShowView:self SelectedRowAtIndexPath:selfIndex  andReturnTheData:_array didSelected:_isSelected];
            }
            [self disMiss];
        }
            break;
        case 1002:{
            [self disMiss];
        }
            break;
        default:
            break;
    }
    
}

#pragma mark -tableView delegate datasouse

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _array.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID=@"aaabbb";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    
    if (cell==nil) {
        cell=[[CFShowViewCell alloc]init];
//        cell.selectionStyle=UITableViewCellSelectionStyleNone;
    }
    
    cell.backgroundColor=[UIColor colorWithRed:239/255.0f green:240/255.0f blue:240/255.0f alpha:1];
    cell.textLabel.text=[_array objectAtIndex:indexPath.row];
    cell.textLabel.textColor=[UIColor colorWithRed:23/255.0f green:23/255.0f blue:23/255.0f alpha:1];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    selfIndex=indexPath.row;
    
//    if () {
//        <#statements#>
//    }
    if ([[_array firstObject]isEqualToString:@"未找到这个人"]) {
        //如果第一个选项是@“未找到这个人”
        _insureBtn.enabled=NO;
        
        return  ;
    }
    
    self.isSelected=YES;
    _insureBtn.enabled=YES;
    
//    NSLog(@"%ld",(long)selfIndex);
    
}

#pragma mark -textField代理方法

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [_textField resignFirstResponder];
    return YES;

}

//- (CGRect)rightViewRectForBounds:(CGRect)bounds{
//    
//    return CGRectMake(bounds.origin.x+bounds.size.width-50,  bounds.origin.y+bounds.size.height-20, 20, 20);
//
//}

#pragma mark -

-(void)show{
    //获取UIWindow对象，将初始化后的bgControl和_tableBgView加载到UIWindow对象中
    UIWindow *keywindow = [[UIApplication sharedApplication] keyWindow];
    [keywindow addSubview:_bgControl];
    [keywindow addSubview:_tableBgView];
    
    [self getURLString];
}

-(void)disMiss{
    [_tableBgView removeFromSuperview];
    [_bgControl removeFromSuperview];

}

-(void)getURLString{
    if (self.delegate&&[_delegate respondsToSelector:@selector(URLStringForSearchAppendingTextFieldText:)]) {
        self.urlString=[_delegate URLStringForSearchAppendingTextFieldText:_textField];
    }
}

-(void)searchButtonDidClicked{
    [_textField resignFirstResponder];
    
    if ([_textField.text isEqualToString:@""]) {
        return;
    }
    
    NSString *str=[_urlString stringByAppendingString:_textField.text];
    NSURL *url=[NSURL URLWithString:str];
    
    self.request=[ASIHTTPRequest requestWithURL:url];
    //设置超时
    _request.timeOutSeconds=7.0;
    [_request startAsynchronous];
    
    __weak typeof(self) weakSelf=self;
    [_request setStartedBlock:^{
        [weakSelf.activityView startAnimating];
        weakSelf.insureBtn.enabled=NO;
    }];
    
    [_request setFailedBlock:^{
//        NSLog(@"网络连接失败");
    }];
    
    [_request setCompletionBlock:^{
        
        [weakSelf.tableView setFrame:CGRectMake(0, weakSelf.titleView.bounds.size.height,weakSelf.tableBgView.bounds.size.width,100)];
        
        [UIView animateWithDuration:0.4 animations:^{
            //控件大小的变化
            [weakSelf.tableBgView setFrame:CGRectMake(25,100,weakSelf.tableBgView.bounds.size.width, 250)];
            //确定按钮的位置变化
            [weakSelf.insureBtn setFrame:CGRectMake(weakSelf.titleView.bounds.size.width/2.0f,  weakSelf.titleView.bounds.size.height+weakSelf.tableView.bounds.size.height+1, weakSelf.tableBgView.bounds.size.width/2.0f, 49)];
            [weakSelf.cancleBtn setFrame:CGRectMake(0, weakSelf.titleView.bounds.size.height+weakSelf.tableView.bounds.size.height+1, weakSelf.tableBgView.bounds.size.width/2.0f-1 , 49)];
        } completion:^(BOOL complete){
        }];
        
        [weakSelf.activityView stopAnimating];
        NSData *data= weakSelf.request.responseData;
        if (weakSelf.delegate&&[weakSelf.delegate respondsToSelector:@selector(CFShowView:arrayFromResponse:)]) {
            
            weakSelf.array=[weakSelf.delegate CFShowView:weakSelf arrayFromResponse:data];
            
            [weakSelf.tableView reloadData];
        }
        
    }];
    
}


@end
