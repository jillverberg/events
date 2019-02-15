    private func show<%= @view_controller_name %>() {
        guard let router = router as? <%= @parent_router_name %>RouterInput else {
            fatalError("\(self) router isn't <%= @parent_router_name %>Router")
        }
        
        router.show<%= @view_controller_name %><%= @type %>()
    }
