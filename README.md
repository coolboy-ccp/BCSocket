# BCSocket
WS for BC
## iOS 10.0 +, swift 5.0+
* pod 'BCSocket'

* 方式一
```
import BCSocket

struct ViewControllerModel: Decodable {
    
}

class ViewController: UIViewController {

    //新建订阅
    private let subscriber = SocketPoolSubscriber<ViewControllerModel>(.markets)
    
    private let socket = SocketPool.connect("url1")
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //订阅消息并设置回调
        subscriber.subcribe("url") { (socket, model) in
            
        }
        
        //取消订阅
        subscriber.unscribe("url")
        
    }

}

```

* 方式二
```
import BCSocket

struct ViewControllerModel: Decodable {
    
}

class ViewController: UIViewController {
     //新建订阅
    private let subscriber = SocketPoolSubscriber<ViewControllerModel>(.markets)
     //新建连接
    private let socket = SocketPool.connect("url1")
    override func viewDidLoad() {
        super.viewDidLoad()
 
        //订阅消息并设置回调
        subscriber.subcribe(socket) { (socket, model) in
            
        }
        //取消订阅    
        subscriber.unscribe(socket)
    }

}

```

