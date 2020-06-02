# BCSocket
WS for BC
## iOS 10.0 +, swift 5.0+
* pod 'BCSocket'
* import BCSocket
* Socket.connect连接
* let subscriber = CommonSubscriber(.markets)，创建一个订阅
* subscriber.subscriber {
//订阅内容回调
}，开始订阅
* subscriber.unsubscribe() 取消订阅
##不需要做任何重连以及断开处理，取消订阅操作只在同一个observer订阅多个message时需要取消上一个订阅(不取消不影响使用，但会耗费流量)
