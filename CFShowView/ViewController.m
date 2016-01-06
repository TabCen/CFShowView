//
//  ViewController.m
//  CFShowView
//
//  Created by  chenfei on 15/12/6.
//  Copyright © 2015年 chenfei. All rights reserved.
//

#import "ViewController.h"
#import "CFShowView.h"

@interface ViewController ()<CFShowViewDelegate>

@property(nonatomic,strong)UIButton *btn;
@property(nonatomic,strong)CFShowView *show;
@property(nonatomic,strong)UILabel *label;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.btn=[[UIButton alloc]initWithFrame:CGRectMake(0, 20, 200, 40)];
    [_btn setBackgroundColor:[UIColor blueColor]];
    [_btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_btn setTitle:@"点击后弹出查询框" forState:UIControlStateNormal];
    [_btn setTitleColor:[UIColor redColor] forState:UIControlStateHighlighted];
    
    [self.view addSubview:_btn];
    
    self.label=[[UILabel alloc]initWithFrame:CGRectMake(0, 100, [UIScreen mainScreen].bounds.size.width, 40)];
    _label.backgroundColor=[UIColor grayColor];
    
    _label.textAlignment=NSTextAlignmentCenter;
    [_label setTextColor:[UIColor blackColor]];
    
    [self.view addSubview:_label];
    
    
}

-(void)btnClick:(UIButton *)button{
    NSLog(@"点击了");
    self.show=[[CFShowView alloc]init];
    _show.delegate=self;
    
    [_show show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

//-(int)CFShowVIew:(CFShowView *)showView numberofCellsInTableView:(UITableView *)tableView{
//    return 10;
//}

-(NSString *)URLStringForSearchAppendingTextFieldText:(UITextField *)textField{
    
    return [NSString stringWithFormat:@"http://bea.wufazhuce.com/OneForWeb/one/getHp_N?strDate=2015-12-07&strRow=%@",textField.text];
}

-(void)CFShowView:(CFShowView *)showView SelectedRowAtIndexPath:(NSInteger)index andReturnTheData:(NSMutableArray *)dataArray didSelected:(BOOL)selected{
    
    if(selected){
//        NSLog(@"你点击了第%ld个cell，内容是%@",(long)index,dataStr);
        _label.text=[NSString stringWithFormat:@"%@",[dataArray objectAtIndex:index]];
    }else{
//        NSLog(@"你没有选择任何人");
        _label.text=@"你没有选择任何人";
    }


}


-(NSMutableArray *)CFShowView:(CFShowView *)showView arrayFromResponse:(NSData *)data{
    
    NSString *str= [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"str = %@",str);
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    NSString *string=[[dic objectForKey:@"hpEntity"] objectForKey:@"strAuthor"];
    
    if (string==nil) {
        return [NSMutableArray arrayWithObject:@"未找到这个人"];
    }
    NSLog(@"%@",string);
    
    return [NSMutableArray arrayWithObject:string];
}

@end
