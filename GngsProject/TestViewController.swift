//
//  TestViewController.swift
//  GngsProject
//
//  Created by 고은지 on 2022/11/22.
//

import UIKit


class TestViewController: UIViewController, UIScrollViewDelegate{

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
            button.customView?.isHidden = false
            
        }
    }

    @IBOutlet weak var button: UIBarButtonItem!
    
    @IBAction func button(_ sender: Any) {
        guard let uvc = self.storyboard?.instantiateViewController(withIdentifier: "Detail") else {
            return
        }
        self.navigationController?.pushViewController(uvc, animated: true)
        
    }
    @IBOutlet var scroll: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.scroll.delegate = self
    }


    @IBOutlet weak var nav: UINavigationItem!
    
    @IBOutlet weak var stackView: UIStackView!
    
    @IBOutlet var scrollView: UIScrollView!
    
//    func scrollViewDidScroll(scrollView: UIScrollView) {
//
//        if (scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.frame.size.height)) {
//            print("bottom")
//        }
//
//        if (scrollView.contentOffset.y < 0){
//            //reach top
//        }
//
//        if (scrollView.contentOffset.y >= 0 && scrollView.contentOffset.y < (scrollView.contentSize.height - scrollView.frame.size.height)){
//            //not top and not bottom
//        }
//    }
    
}
