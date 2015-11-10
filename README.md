# UIFaceGestureKit
ObjC framework for working with face gestures (eye and smile) 

## Demo
Run Showcase (only on device) and follow the instructions: 
1. Place you face in front of the camera.  
2. Close one eye and see how tableview row selection changes. 

## Usage

UITableView:
```
#import "UIFaceGestureKit/UIFaceGestureKit.h"

    self.tableView.faceInteractionEnabled = YES;
    self.tableView.eyeScrollingEnabled = YES;
    // self.tableView.eyeSelectionEnabled = YES;
    // self.tableView.eyeScrollingCircle = YES;
    
```

UICollectionView: 
```
    collectionView.faceInteractionEnabled = YES;
    collectionView.eyeScrollingEnabled = YES;
    collectionView.eyeScrollingDelay = 0.3;
    // collectionView.eyeSelectionEnabled = YES;
    // collectionView.eyeScrollingCircle = YES;
```

UITextField: 
```
   [_textField setEyeKeyboardInput:YES];
```

Any direct usage of:
```
#import "UIFaceGestureKitEyeGestures.h"
#import "UIFaceGestureKitSmileGestures.h"
```

## Contributing

1. Fork it!
2. Create your feature branch: `git checkout -b my-new-feature`
3. Commit your changes: `git commit -am 'Add some feature'`
4. Push to the branch: `git push origin my-new-feature`
5. Submit a pull request :D

## TODO

Documentation and tests (?).  

## License

Apache 2.0.
