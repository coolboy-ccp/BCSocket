# BCSocket
WS for BC
## iOS 10.0 +, swift 5.0+
* pod 'BCSocket'
```
import BCSocket

//消息解析后的model
struct ViewControllerModel: Decodable {
    
}

class ViewController: UIViewController {
    //需要订阅的消息
    private let ws = SocketSubscriber<ViewControllerModel>(.markets)

    override func viewDidLoad() {
        super.viewDidLoad()
        //连接，全局只保持一个
        Socket.connect("")
        //开始订阅及订阅消息回调
        ws.subcribe { (model) in

        }
    }
}

```
##不需要做任何重连以及断开处理，取消订阅操作只在同一个observer订阅多个message时需要取消上一个订阅(不取消不影响使用，但会耗费流量)
