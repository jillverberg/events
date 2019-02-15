    func show<%= @router_name %>Router() {
        let router = <%= @router_name %>Router(parentRouter: self)
        self.showRouter(router)
    }
