    
    func show<%= @view_controller_name %>ViewController() {
        let viewController = setup<%= @view_controller_name %>ViewController()
        self.rootNavigationController?.pushViewController(viewController, animated: true)
    }

