   
   private func setup<%= @view_controller_name %>ViewController() -> UIViewController {
        let storyboardViewController = StoryboardViewController(storyboardName: .main, identifier: <%= @view_controller_identifier %>)
        let viewController = self.createViewController(from: storyboardViewController) as! <%= @view_controller_name %>ViewController
        
        return viewController
    }

   
