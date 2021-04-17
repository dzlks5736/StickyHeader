//
//  ViewController.swift
//  StickyHeader
//
//  Created by SIU on 2021/04/17.
//

import UIKit

let maxHeight: CGFloat = 350
let minHeight: CGFloat = 100
var savedOffset: CGFloat?

class MainViewController: UIViewController {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var upperHeaderView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var pageViewContainer: UIView!
    
    @IBOutlet weak var heightConstraint: NSLayoutConstraint! {
        didSet {
            heightConstraint.constant = maxHeight
        }
    }
    
    var pageViewController : UIPageViewController!
    var orderedViewControllers : [UIViewController] = []
    
    var mode : Int = 0 {
        
        didSet {
            if mode == 0 {
                if let firstViewController = orderedViewControllers.first {
                    pageViewController.setViewControllers(
                        [firstViewController],
                        direction: .reverse,
                        animated: true,
                        completion: nil)

                }
                segmentedControl.selectedSegmentIndex = 0
                
            }else if mode == 1 {
                if let firstViewController = orderedViewControllers.last {
                    pageViewController.setViewControllers(
                        [firstViewController],
                        direction: .forward,
                        animated: true,
                        completion: nil)
                }
                segmentedControl.selectedSegmentIndex = 1
                
            }
        }
        
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        orderedViewControllers.append(newVc(viewController: "FirstViewController"))
        orderedViewControllers.append(newVc(viewController: "SecondViewController"))
        
        pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "pageViewController") as? UIPageViewController
        
        pageViewController.view.frame = CGRect(x: 0, y: 0, width: Int(pageViewContainer.frame.size.width), height: Int(pageViewContainer.frame.size.height))
        
        self.addChild(pageViewController)
        pageViewContainer.addSubview(pageViewController.view)

        pageViewController.dataSource = self
        pageViewController.delegate = self

        if let firstViewController = orderedViewControllers.first {
            pageViewController.setViewControllers(
                [firstViewController],
                direction: .forward,
                animated: true,
                completion: nil)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNoti(_:)), name: NSNotification.Name(rawValue: "scroll"), object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func pressSegment(_ sender: Any) {
        if mode == 0 {
            mode = 1
        } else if mode == 1 {
            mode = 0
        }
    }
    
    func newVc(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    @objc func handleNoti(_ noti: Notification) {
        
        let offset = noti.object as! CGFloat
        savedOffset = offset
                        
        if offset < 0 {
            heightConstraint.constant = max(abs(offset), minHeight)
        } else {
            heightConstraint.constant = minHeight
        }
        let percentage = (-offset-100)/50
        
        upperHeaderView.alpha = percentage
    }

}

extension MainViewController: UIPageViewControllerDataSource , UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if finished {
            if pageViewController.viewControllers![0] is FirstViewController {
                mode = 0
            }else if pageViewController.viewControllers![0] is SecondViewController {
                mode = 1
            }
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1

        guard previousIndex >= 0 else {
            return orderedViewControllers.last
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let viewControllerIndex = orderedViewControllers.firstIndex(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        guard orderedViewControllersCount != nextIndex else {
            return orderedViewControllers.first
        }
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        return orderedViewControllers[nextIndex]
    }
    
}
