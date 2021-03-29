# CCModel
### 在json 和 模型之间 快速进行映射
![](http://upload-images.jianshu.io/upload_images/904261-7ae62d8f615f5e68.jpg?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)
### API

    CCGHUser *model = [CCGHUser cc_modelFromJson:data];  //json  ->  Model
    NSLog(@"%@",[model cc_modelToDictionary]);   //model  ->  Dic
