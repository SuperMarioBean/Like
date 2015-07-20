platform :ios, '7.0'
# source 'https://github.com/CocoaPods/Specs.git'
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
    ## 多 storyboard 的组合使用
    pod 'RBStoryboardLink', '~> 0.1.4'
    ## 动画效果引擎
    pod 'pop', '~> 1.0.7'
    ## 网络库
    pod 'AFNetworking', '~> 2.5.4'
    ## 模型框架
    pod 'Mantle', '~> 2.0.2'
    ## 日志
    #pod 'CocoaLumberjack', '~> 2.0.0'
    ## UIKit 组件封装
    ### 进度
    pod 'THProgressView', '~> 1.0'
    ### UIAlert分装 (考虑后期更换为UIAlertController)
    pod 'UIAlert+Blocks', '~> 1.0.2'
    ### UICollectionView增强
    ### 底部刷新
    pod 'CCBottomRefreshControl'
    #### 瀑布流
    pod 'CHTCollectionViewWaterfallLayout', '~> 0.9.1'
    #### 缓存高度
    pod 'UICollectionView-ARDynamicHeightLayoutCell', :git => 'https://github.com/SuperMarioBean/UICollectionView-ARDynamicHeightLayoutCell.git'
    #### 进度条
    pod 'MBProgressHUD', '~> 0.9.1'
    #### 进度条扩展
    pod 'MBProgressHUDExtensions@donly', '~> 0.3'
    #### 下拉刷新
    pod 'SSPullToRefresh', :git => 'git@github.com:SuperMarioBean/sspulltorefresh.git'
    #### UIBarButtonItem角标扩展
    pod 'UIBarButtonItem-Badge', :git => 'git@github.com:mikeMTOL/UIBarButtonItem-Badge.git'

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
