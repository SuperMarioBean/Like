platform :ios, '7.1'

source 'https://github.com/CocoaPods/Specs.git'
source 'https://github.com/SuperMarioBean/SMBSpecs.git'

target :like do
    # 基础框架
    ## 环信集成(IM和实时语音)
    pod 'EaseMobSDKFull', '~> 2.1.7';

    ## 支付
    pod 'Pingpp/Alipay', '~> 2.0.5'
    pod 'Pingpp/Wx', '~> 2.0.5'
    pod 'Pingpp/ApplePay', '~> 2.0.5'
    ## 影像获取
    pod 'PBJVision'
    ## 图片剪切
    pod 'HIPImageCropper'
    ## 交互式滤镜
    pod 'SCRecorder'
    ## 广播代理
    pod 'MulticastDelegate', '~> 0.0.1.1'
    ## 页面布局
    pod 'Masonry', '~> 0.6.1'
    ## 全局图片缓存
    pod 'SDWebImage', '~> 3.7.2'
    ## 动画效果引擎
    pod 'pop', '~> 1.0.7'
    ## 网络库
    pod 'AFNetworking', '~> 2.5.4'
    ## 模型框架
    pod 'Mantle', '~> 2.0.2'
    ## 日志
    #pod 'CocoaLumberjack', '~> 2.0.0'
    ## 定位
    
#    pod 'LIKELocation', :path => '/Users/David/Documents/david_fu@bitbucket.org/LIKELocation'
#    pod 'LIKENetworkLayer', :path => '/Users/David/Documents/david_fu@bitbucket.org/LIKENetworkLayer'
#    pod 'LIKENetworkStatus', :path => '/Users/David/Documents/david_fu@bitbucket.org/LIKENetworkStatus'

    pod 'LIKELocation', :git => 'https://David_Fu@bitbucket.org/TrinityLike/likelocation.git'
    pod 'LIKENetworkLayer', :git => 'https://David_Fu@bitbucket.org/TrinityLike/likenetworklayer.git'
    pod 'LIKENetworkStatus', :git => 'https://David_Fu@bitbucket.org/TrinityLike/likenetworkstatus.git'

    ## UIKit 组件封装
    ### 进度
    pod 'THProgressView', '~> 1.0'
    
    ### UIAlertController, UIAlertView, UIActionSheet 的 iOS7 兼容封装
    pod 'PSTAlertController', '~> 1.1.0'
    
    ### UICollectionView增强
    ### 底部刷新
    pod 'CCBottomRefreshControl'
    ### 瀑布流
    #pod 'CHTCollectionViewWaterfallLayout', '~> 0.9.1'
    ### 缓存高度
    pod 'UICollectionView-ARDynamicHeightLayoutCell', :git => 'https://github.com/SuperMarioBean/UICollectionView-ARDynamicHeightLayoutCell.git'
    ### 进度条
    pod 'MBProgressHUD', '~> 0.9.1'
    ### 进度条扩展
    pod 'MBProgressHUDExtensions@donly', '~> 0.3'
    ### 下拉刷新
    pod 'SSPullToRefresh', :git => 'https://github.com/SuperMarioBean/sspulltorefresh.git'
    ### UIBarButtonItem角标扩展
    pod 'UIBarButtonItem-Badge', :git => 'https://github.com/mikeMTOL/UIBarButtonItem-Badge.git'
#    pod 'ICETutorial', :git => 'https://github.com/SuperMarioBean/ICETutorial.git'

    ### storybrd 增强
    #### custom relationship storyboard segue
    # pod 'SMBCustomRelationshipSegue', :path => '/Users/David/Documents/supermariobean@github.com/SMBCustomRelationshipSegue'
    pod 'SMBCustomRelationshipSegue'

    #### perform segue replace
    pod 'UIViewController+BlockSegue'
    #### 多 storyboard 的组合使用
    pod 'RBStoryboardLink', '~> 0.1.4'

    #  开发辅助
    ##   UI分析
    pod 'Reveal-iOS-SDK', :configurations => ['Debug']
    ##   崩溃日志上传
    pod 'FIR.im', '~> 1.2.0', :configurations => ['Release']
    ##pod 'HockeySDK', '~> 3.6.4'
end

target :likeTests do
    # 界面测试
    pod 'KIF', '~> 3.2.2'
    # BDD 测试
    pod 'Specta', '~> 1.0.0'
    pod 'Expecta', '~> 1.0.0'
    pod 'OCMock', '~> 3.1.2'
end
