//
//  WelcomeViewController.swift
//  Spotify
//
//  Created by Дмитрий Старков on 19.03.2021.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    private let signInButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("Sign In with Spotify", for: .normal)
        button.setTitleColor(.black, for: .normal)
        return button
    }()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "albums_background")
        return imageView
    }()

    private let overlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.7
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "AppIcon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        label.text = "Listen to Millions\nof Song on\nthe go"
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Spotify"
        
        view.addSubview(imageView)
        view.addSubview(overlayView)
        view.addSubview(label)
        view.addSubview(logoImageView)
        view.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(didTapSignIn), for: .touchUpInside)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = view.bounds
        overlayView.frame = view.bounds
        signInButton.frame = CGRect(
        x: 20,
        y: view.height - 50 - view.safeAreaInsets.bottom,
        width: view.widht - 40,
        height: 50)
        
        logoImageView.frame = CGRect(x: (view.widht - 120)/2, y: (view.height - 350)/2, width: 120, height: 120)
        label.frame = CGRect(x: 30, y: logoImageView.bottom + 60, width: view.widht - 60, height: 150)
    }

    @objc func didTapSignIn() {
        let vc = AuthViewController()
        vc.compelionHandler = { [weak self] success in
            DispatchQueue.main.async {
                self?.handlerSignIn(success: success)
            }
        }
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func handlerSignIn(success: Bool) {
        //Log user in yell at them for error
        guard success else {
            let alert = UIAlertController(title: "Oops",
                                        message: "Something went wrong when singing in",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
            present(alert, animated: true)
            return
        }
        let mainAppTabBarVC = TabBarViewController()
        mainAppTabBarVC.modalPresentationStyle = .fullScreen
        present(mainAppTabBarVC, animated: true)
    }
}
