    
    func showInitialViewController(navigationController: UINavigationController) {
        let viewController = setup<%= @view_controller_name %>ViewController()
        setViewControllersWithFadeAnimation(viewControllers, navigationController: navigationController)
    }

