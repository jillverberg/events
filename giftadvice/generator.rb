require 'yaml'
require 'thor'
require 'fastlane'
require 'xcodeproj'
require 'net/http'
require 'uri'
require 'colorize'
require 'gitlab'

class CertificateManager < Thor
  include Thor::Actions

  CertificateManager.source_root(Dir.pwd)

  APP_DIRECTORY = File.dirname(__FILE__)
  COMPANY_IDENTIFIERS = 'com.fora-soft'
  APP_NAME = 'Some App' #Given from Xcode project

  # set an API endpoint
  GITLAB_ENDPOINT = 'https://s2.git.fora-soft.com/api/v4'
  GITLAB_PRIVATE_KEY = 'SxHxy8ZRb--NU_EPRdXP'

  APP_CONFIGURATIONS =  "DEV,TEST,DEMO"

  BASED_FILES_GENERATED =  {
      'Appfile' => 'fastlane',
      'Fastfile' => 'fastlane',
      'Matchfile' => 'fastlane'
  }

  desc 'init', 'Create new xcode project'
  def init
    ENV['GITLAB_API_ENDPOINT'] = "https://s2.git.fora-soft.com"
    ENV['GITLAB_API_PRIVATE_TOKEN'] = "SxHxy8ZRb--NU_EPRdXP"

    print("===========================================================\n".blue)
    print("==== # ForaSoft Swift project generator by George E. # ====\n".light_blue)
    print("===========================================================\n".blue)

    # Open Xcode project
    folder_name = Dir.pwd.split('/').last

    project =  Xcodeproj::Project.open("#{folder_name}.xcodeproj")

    # Show information

    print("You want to setup \"#{folder_name}\"\nThe project already have #{project.build_configurations.count} build configurations:\n".magenta)
    project.build_configurations.each() do |config|
      print("#{config.name}\n".cyan)
    end

    # Ask for parameters
    configuration = invoke(:configure, [])
    # GitLab run
    #createGitRepo configuration

    # Generate class
    generateClass(configuration, project)

    # Setup Xcode variables
    setupProject(configuration, project)

    # Create fastlane config from configuration
    createFastlaneFiles(configuration)

    # Fastlane run
    create = ask("Do you want to run Fastlane (Create app identifier, provisioning profile and etc.?\n Write y/n <= ")

    if create == "y"
      exec('fastlane ios initialise')
    end



  end

  desc 'generateClass', 'Setup project variables'
  def generateClass(configuration, project)
    RouterGenerator.new.init configuration, project #init(configuration)
  end

  # # # #
  # # # #
  #
  # ===== Setup project variables
  #
  # # # #
  # # # #

  desc 'setupProject', 'Setup project variables'
  def setupProject(configuration, project)
    # Parse configuration
    configurations = configuration[:app_configuration]
    hockey_configurations = configuration[:hockey_app_configuration]
    app_name = configuration[:app_name]
    folder_name = configuration[:folder_name]
    app_prefix = configuration[:app_prefix]

    # Set custom identifier
    info_plist = Xcodeproj::Plist.read_from_path("#{folder_name}/info.plist")
    info_plist['CFBundleDisplayName'] = "$(#{app_prefix}_bundle_display_name)"
    info_plist['ConstantsDictionary'] = {
        'server_port'  => "$(#{app_prefix.downcase}_server_port)",
        'server_url'   => "$(#{app_prefix.downcase}_server_url)",
        'socket_token' => "$(#{app_prefix.downcase}_socket_token)",
        'hockeyapp_app_identifier' => "$(#{app_prefix.downcase}_hockeyapp_app_identifier)"
    }
    Xcodeproj::Plist.write_to_path(info_plist,"#{folder_name}/info.plist")

    uuid_configuration = {}
    # Add configuration
    configurations.split(",").each() do |value|
      app_identifier = COMPANY_IDENTIFIERS + ".#{app_name}"  +  ".#{value.downcase}"

      configuration = project.add_build_configuration("#{value.downcase}", :debug)
      project.targets.first.add_build_configuration "#{value.downcase}", :debug
      project.save
      print("Configuration #{value} added.\nBundle identifier #{app_identifier}. Bundle name #{value.upcase + " " + app_name}\n")
      uuid_configuration[configuration.uuid] = value
    end

    print("\n\nSet project custom variables\n".yellow)
    print("============================\n\n".yellow)

    create = ask("Do you want to set properties? (also Hockeapp) \n Write y/n <= ")

    if create == "y"
      list = Xcodeproj::Plist.read_from_path("#{folder_name}.xcodeproj/project.pbxproj")
      uuid_configuration.each() do |key, value|
        app_identifier = COMPANY_IDENTIFIERS + ".#{app_name.gsub(/\s+/, "")}"  +  ".#{value.downcase}"

        # Bundle identifier
        list['objects'][key]['buildSettings']['PRODUCT_BUNDLE_IDENTIFIER'] = app_identifier
        list['objects'][key]['buildSettings']['SWIFT_VERSION'] = '4.0'

        hockey = hockey_configurations.split(",").select{|name| name == value}
        if hockey.count == 1
          list['objects'][key]['buildSettings']["#{app_prefix.downcase}_hockeyapp_app_identifier"] = "#{createHockeyApp app_name + " " +value.upcase, app_identifier}"
        end

        # Custom keys
        list['objects'][key]['buildSettings']["#{app_prefix.downcase}_bundle_display_name"] = value.upcase + " " + app_name
        list['objects'][key]['buildSettings']["#{app_prefix.downcase}_server_port"] = ask("Enter server port for #{value} <= ")
        list['objects'][key]['buildSettings']["#{app_prefix.downcase}_server_url"] = ask("Enter server url for #{value} <= ")
        list['objects'][key]['buildSettings']["#{app_prefix.downcase}_socket_token"] = ask("Enter socket token for #{value} <= ")
      end

      Xcodeproj::Plist.write_to_path(list,"#{folder_name}.xcodeproj/project.pbxproj")
    end
  end

  # # # #
  # # # #
  #
  # ===== Hockey app function
  #
  # # # #
  # # # #

  desc 'createHockeyApp', 'Create hockey app'
  def createHockeyApp(name, bundle_identifier)

    print("\nHockeyapp app creation. (Search in existing..)\n".yellow)

    public_identifier = ''

    uri = URI.parse("https://rink.hockeyapp.net/api/2/apps/new")

    uriAll = URI.parse("https://rink.hockeyapp.net/api/2/apps")

    header = {'X-HockeyAppToken': "e34e8bc176ac4950a8233d17e1b74cd7"}

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE

    request = Net::HTTP::Get.new(uriAll.request_uri,header)
    response = http.request(request)

    if JSON.parse(response.body)['status'] == 'success'
      print("HTTP:: => Get Success\n".green)
    else
      print("HTTP:: => Error\n #{response.body}\n".red)
      ask("Should stop the script")
    end

    create_new = true
    JSON.parse(response.body)['apps'].each() do |app|
      if app['title'] == name
        create_new = false
        public_identifier = app['public_identifier']
        print("Existing app found \"#{name}\" with identifier \"#{public_identifier}\"\n".green)
      end
    end

    if create_new
      print("App not found\n".yellow)
      user = {
          title: name,
          bundle_identifier: bundle_identifier
      }
      print("Create new app \"#{name}\" with identifier \"#{bundle_identifier}\"\n".yellow)
      request = Net::HTTP::Post.new(uri.request_uri,header)
      request.body = URI.encode_www_form(user)
      response = http.request(request)
      if JSON.parse(response.body).has_key?("errors")
        print("HTTP:: => Error\n #{response.body}\n".red)
        ask("Should stop the script".red)
      else
        print("HTTP:: => Post Success\n".green)
      end

      public_identifier = JSON.parse(response.body)['public_identifier']
    end

    public_identifier
  end

  # # # #
  # # # #
  #
  # ===== Gitlab functions
  #
  # # # #
  # # # #

  desc 'createGitRepo', 'Create new xcode project'
  def createGitRepo(configuration)

    # set an API endpoint
    Gitlab.endpoint = GITLAB_ENDPOINT
    # set a user private token
    Gitlab.private_token = GITLAB_PRIVATE_KEY

    client = Gitlab.client(endpoint: Gitlab.endpoint, private_token: Gitlab.private_token)

    if configuration[:internal_gitlab_project_identifier].nil?
      created_project = client.create_project "#{configuration[:app_name]}-iOS", {:visibility => "private"}
      project_identifier = created_project.to_hash['id']
      print("Project \"#{configuration[:app_name]}\" created with identifier #{project_identifier}")

      client.share_project_with_group(project_identifier,3, 30)
      client.create_branch(project_identifier, "dev","master")

      configuration[:internal_gitlab_project_identifier] = created_project.to_s['id']
      File.open(CONFIG_FILE, 'w') do |f|
        f.write configuration.to_yaml
      end
    end

    project_identifier = configuration[:internal_gitlab_project_identifier]

    # Generate actions
    # actions = Array.new
    #
    # files = rec_path(Pathname.new('.'), true)
    # files.each do |file|
    #   if file.file?
    #     open = File.open(file.to_s)
    #     content = open.read
    #     if actions.count < 2
    #       actions.push({
    #                        :action => "create",
    #                        :file_path => file.to_s,
    #                        :content => "content"
    #                    })
    #     end
    #   end
    # end

    # print "Content created\n #{actions} #{project_identifier}"

    client.create_commit project_identifier, "dev","Generated project",[{"action" => "creacte","file_path" => "file.txt","content" => "contccent"}]

    #print created_response.to_s

    ask("All done!")

  end

  desc 'rec_path', 'Create new xcode project'
  def rec_path(path, file= false)
    puts path
    path.children.collect do |child|
      if child.to_s != "templates" && child.to_s != "fora.yml" && child.to_s != "generator.rb"
        if file and child.file?
          child
        elsif child.directory?
          rec_path(child, file) + [child]
        end
      end
    end.select { |x| x }.flatten(1)
  end

  # # # #
  # # # #
  #
  # ===== Fastlane generators function
  #
  # # # #
  # # # #

  desc 'createFastlaneFiles', 'Create new xcode project'
  def createFastlaneFiles(configuration)
    # Parse configuration
    configurations = configuration[:app_configuration]
    app_name = configuration[:app_name]

    # Create empty directories
    empty_directory 'fastlane', :verbose => false

    #Appfile
    @apple_id = "vladimir@fora-soft.com"
    template "templates/fastlane/Appfile", "fastlane/Appfile", {:force => true, :verbose => false}

    #Fastfile
    @produce = ""
    app_identifiers = Array.new
    configurations.split(",").each do |value|
      @app_identifier = COMPANY_IDENTIFIERS + ".#{app_name.gsub(/\s+/, "")}"  +  ".#{value.downcase}"
      app_identifiers.push @app_identifier
      @app_name = app_name + " #{value}"

      template "templates/fastlane/template_methods/Produce", "templates/fastlane/template_methods/temp", {:force => true, :verbose => false}
      @produce = @produce + IO.read("#{APP_DIRECTORY}/templates/fastlane/template_methods/temp")
    end

    template "templates/fastlane/Fastfile", "fastlane/Fastfile", {:force => true, :verbose => false}

    #Matchfile
    @app_identifiers = app_identifiers.join'","'
    template "templates/fastlane/Matchfile", "fastlane/Matchfile", {:force => true, :verbose => false}

    #Gemfile
    template "templates/fastlane/Gemfile", "Gemfile", {:force => true, :verbose => false}
  end

  # # # #
  # # # #
  #
  # ===== Configuration functions
  #
  # # # #
  # # # #

  CONFIG_FILE = 'fora.yml'

  desc 'configure', 'configures project properties'
  def configure
    print("\n\nConfigure parameters of project\n".yellow)
    print("===============================\n".yellow)
    print("can also set in .fora.tml\n\n")

    config = File.exists?(CONFIG_FILE) ? YAML.load_file(CONFIG_FILE) : {}

    folder_name = Dir.pwd.split('/').last
    projects =  Xcodeproj::Project.open("#{folder_name}.xcodeproj")

    project      = projects.root_object.name
    author       = ask("Author #{config[:author]} ?")
    app_prefix   = ask("Enter app_prefix for \"#{folder_name}\" <= #{config[:app_prefix]} ?")
    app_configuration = ask("New app build configuration (separeted by comma) <= #{config[:app_configuration]} ? ")
    hockey_app_configuration = ask("Hockey app build configuration (separeted by comma, needs to be one of new) <= #{config[:hockey_app_configuration]} ? ")

    config[:app_name] = projects.root_object.name
    config[:folder_name] = folder_name

    config[:project]      = project.empty?      ? config[:project] || ''      : project
    config[:author]       = author.empty?       ? config[:author] || ''       : author
    config[:app_prefix]       = app_prefix.empty?       ? config[:app_prefix] || ''       : app_prefix
    config[:app_configuration]       = app_configuration.empty?       ? config[:app_configuration] || ''       : app_configuration
    config[:hockey_app_configuration]       = hockey_app_configuration.empty?       ? config[:hockey_app_configuration] || ''       : hockey_app_configuration

    config[:app_prefix] = config[:app_prefix].upcase

    File.open(CONFIG_FILE, 'w') do |f|
      f.write config.to_yaml
    end

    config
  end
end

class RouterGenerator < Thor
  include Thor::Actions

  RouterGenerator.source_root(File.dirname(__FILE__))

  # Dictionary

  BASED_FILES_GENERATED =  {
      'Router' => 'Routers/',
      'ViewController' => 'View Controllers/'
  }

  FILES_GENERATED =  {
      'LaunchRouter' => 'Routers/',
      'AppDelegate' => '',
      'InfoPlistService' => 'Services/',
      'SocketManager' => 'Managers/',
      'NetworkManager' => 'Managers/',
      'AssemblyManager' => 'Managers/',
      'Reachability' => 'Others/',
      'ThreadSafely' => 'Others/',
      'SocketKeysAndEvents' => 'Others/',
      'ApplicationResources' => 'Others/',
      'ErrorsTexts' => 'Others/'
  }

  CUSTOM_ROUTERS = {
      'AuthRouter' => 'Routers/',
      'LoginRouter' => 'Routers/'
  }

  # # # #
  # # # #
  #
  # ===== Class generator
  #
  # # # #
  # # # #

  desc 'init', 'initializes VIPER project'
  def init(configuration, project)
    print("\nGenerating classes\n".yellow)
    print("==================\n".yellow)

    # Create empty directories
    # empty_directory 'Classes'
    folder_name = Dir.pwd.split('/').last
    main_target = project.targets.first

    # Add config
    @project = configuration[:project]
    @prefixed_module = configuration[:app_prefix]
    @author  = configuration[:author]
    @date    = Time.now.strftime('%d/%m/%y')
    @show_router_function =  invoke(:createRouterShowFunction, [])

    router_group = createGroup "Routers", project
    service_group = createGroup "Services", project
    manager_group = createGroup "Managers", project
    other_group = createGroup "Others", project
    view_controller_group = createGroup "View controllers", project

    groups = {
        'Routers/' => router_group,
        'Services/' => service_group,
        'Managers/' => manager_group,
        'Others/' => other_group,
        'View Controllers/' => view_controller_group,
        '' => project.groups.first
    }

    # ==============
    # Generate files
    base_files = BASED_FILES_GENERATED

    #Podfile
    template "templates/Podfile", "Podfile", {:force => true, :verbose => false}

    base_files.each() do |file_name, folder|
      file_path = "#{folder_name}/#{folder}#{@prefixed_module}#{file_name}.swift"
      template "templates/#{file_name}.swift", file_path, {:force => true, :verbose => false}

      # Add files to Xcode
      createClass "#{folder}#{@prefixed_module}#{file_name}.swift", groups[folder], main_target
    end

    files = FILES_GENERATED

    files.each do |file_name, folder|
      file_path = "#{folder_name}/#{folder}#{file_name}.swift"
      template "templates/#{file_name}.swift", file_path, {:force => true, :verbose => false}

      # Add files to Xcode
      createClass "#{folder}#{file_name}.swift", groups[folder], main_target
    end

    # =========================
    # Create additional routers

    add_routers = configuration[:app_routers].split(',') #ask("Enter additional routers (comma separated) <= ")
    add_view_controllers = configuration[:app_view_controllers].split(',') #ask("Enter additional view controllers (comma separated) <= ")

    add_routers = add_routers.map {|name| name.downcase.capitalize}
    add_view_controllers = add_view_controllers.map {|name| name.downcase.capitalize}

    print("Available routers: \n")
    add_routers.each do |router_name|
      print("#{router_name}\n")
    end
    print("Available view controllers: \n")
    add_view_controllers.each do |view_controller_name|
      print("#{view_controller_name}\n")
    end

    relashion = eval(configuration[:router_relashion])
    dependence = eval(configuration[:dependence])

    @router_protocols = ''
    add_routers.each do |router_name|
      routers_to_show = relashion[:"#{router_name}"]  #ask("R: 1. Enter ROUTERS to show from #{router_name}Router (comma separated) <= ")
      view_controllers_to_show = dependence[:"#{router_name}"] #ask("R: 2. Enter VIEW CONTROLLERS that #{router_name}Router contain (comma separated) <= ")

      if routers_to_show.nil?
        routers_to_show = ""
      end
      if view_controllers_to_show.nil?
        view_controllers_to_show = ""
      end

      createRouter router_name, folder_name, main_target, view_controllers_to_show.split(','), routers_to_show.split(','), project

      # Create additional view controllers
      createViewControllers view_controllers_to_show.split(','), folder_name, main_target, router_name, project, configuration

      @router_protocols = @router_protocols + createRouterProtocols(router_name, view_controllers_to_show.split(','), routers_to_show.split(','))
    end

    # Generate protocol
    template "templates/RouterProtocol.swift", "#{folder_name}/Routers/#{@prefixed_module}RouterProtocol.swift", {:force => true, :verbose => false}

    router_group = createGroup "Routers", project
    createClass "Routers/#{@prefixed_module}RouterProtocol.swift", router_group, main_target

    project.save "#{folder_name}.xcodeproj"
  end

  # # # #
  # # # #
  #
  # ===== Help functions
  #
  # # # #
  # # # #

  desc 'createGroup', 'Create group, if exist => return'
  def createGroup(name, project)
    group = project.groups.first.groups.select{|group| group.name == name}
    if group.count == 0
      group = project.groups.first.new_group name
    else
      group = group.first
    end

    group
  end

  desc 'createClass', 'Create class file, if exist => return'
  def createClass(path, group, main_target)
    file = group.files.select{|file| file.path == path}
    if file.count != 0
      file.first.remove_from_project
    end

    file = group.new_file path
    main_target.add_file_references([file])
  end

  desc 'generateViewControllerShow', 'Create class file, if exist => return'
  def generateViewControllerShow(type, name)
    @type = type
    @view_controller_name = name
    template "templates/template_methods/ViewControllerShowMethods.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
    IO.read("templates/template_methods/temp.swift")
  end

  desc 'generateViewControllerShowProtocol', 'Create class file, if exist => return'
  def generateViewControllerShowProtocol(type, name)
    @type = type
    @view_controller_name = name
    template "templates/template_methods/RouterProtocolShowMethod.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
    IO.read("templates/template_methods/temp.swift")
  end
  # # # #
  # # # #
  #
  # ===== Create view controllers
  #
  # # # #
  # # # #

  desc 'createViewControllers', 'Create class file, if exist => return'
  def createViewControllers(view_controllers, folder_name, main_target, router, project, configuration)
    # view controllers - view controllers that needs to create, from one router

    createViewControllersConstants view_controllers, folder_name, main_target, project
    vc_to_router = eval(configuration[:view_controller_to_router_relashion])
    vc = eval(configuration[:view_controller_relashion])

    view_controllers.each do |view_controller_name|
      routers_to_show = vc_to_router[:"#{view_controller_name}"] #ask("VC: 3.#{index+1} Enter ROUTERS to show from #{view_controller_name}ViewController EXTERNAL (comma separated) <= ")
      view_controllers_to_show = vc[:"#{view_controller_name}"] #ask("VC: 4.#{index+1} Enter VIEW CONTROLLERS to show from #{view_controller_name}ViewController INTERNAL (comma separated) <= ")

      if routers_to_show.nil?
        routers_to_show = ""
      end
      if view_controllers_to_show.nil?
        view_controllers_to_show = ""
      end

      createViewController view_controller_name, folder_name, router, view_controllers_to_show.split(','), routers_to_show.split(','), main_target, project
    end

  end

  desc 'createViewController', 'Create class file, if exist => return'
  def createViewController(name, folder_name, router, view_controllers, routers, main_target, project)
    # name - name of creating view controller
    # router - router where view controller was presented
    # view_controllers - all view controllers that should be showed
    # routers - all routers that should be showed
    @show_view_controllers = ''
    @parent_router_name = router

    view_controllers.each do |name|
      @show_view_controllers = @show_view_controllers + generateViewControllerShow('ViewController', name)
    end
    routers.each do |name|
      @show_view_controllers = @show_view_controllers + generateViewControllerShow('ViewController', name)
    end

    # Create view controller constants
    file_path = "#{folder_name}/View Controllers/#{name}ViewController.swift"
    template "templates/C_ViewController.swift", file_path, {:force => true, :verbose => false}

    view_controller_group = createGroup "View controllers", project
    createClass "View Controllers/#{name}ViewController.swift", view_controller_group, main_target
  end

  desc 'createViewControllersConstants', 'Create class file, if exist => return'
  def createViewControllersConstants(view_controllers, folder_name, main_target, project)
    # Generate view controller identifiers
    @storyboard_identifiers = ''
    view_controllers.each do |name|
      @view_controller_name = name.downcase
      @view_controller = name
      template "templates/template_methods/ViewControllerIdentifier.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
      @storyboard_identifiers = @storyboard_identifiers + IO.read("templates/template_methods/temp.swift")
    end

    # Create view controller constants
    file_path = "#{folder_name}/Others/StoryboardViewController.swift"
    template "templates/StoryboardViewController.swift", file_path, {:force => true, :verbose => false}

    other_group = createGroup "Others", project
    createClass "Others/StoryboardViewController.swift", other_group, main_target
  end

  # # # #
  # # # #
  #
  # ===== Create routers
  #
  # # # #
  # # # #

  desc 'createRouter', 'Create class file, if exist => return'
  def createRouter(name, folder_name, main_target, view_controllers, routers, project)
    # Generate show and setup view_controllers methods

    # view_controllers - view controllers, that can showed (first is initial)
    # routers - routers, that can showed
    # Initial view controller

    @view_controller_name = view_controllers.first
    template "templates/template_methods/RouterVCMethodsInit.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
    @protocol_methods = IO.read("templates/template_methods/temp.swift")

    # Show
    view_controllers.each_with_index do |name, index|
      next if index == 0
      @view_controller_name = name
      template "templates/template_methods/RouterVCMethods.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
      @protocol_methods = @protocol_methods + IO.read("templates/template_methods/temp.swift")
    end

    # Setup
    @view_controller_setup = ''
    view_controllers.each do |name|
      @view_controller_name = name
      @view_controller_identifier = ".#{name.downcase}"
      template "templates/template_methods/RouterVCSetup.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
      @view_controller_setup = @view_controller_setup + IO.read("templates/template_methods/temp.swift")
    end

    # Generate show routers methods

    routers.each do |name|
      @router_name = name
      template "templates/template_methods/RouterMethods.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
      @protocol_methods = @protocol_methods + IO.read("templates/template_methods/temp.swift")
    end

    # Create router
    @router_name = name

    file_path = "#{folder_name}/Routers/#{name}Router.swift"
    template "templates/C_Router.swift", file_path, {:force => true, :verbose => false}

    router_group = createGroup "Routers", project
    createClass "Routers/#{name}Router.swift", router_group, main_target
  end

  desc 'createRouterProtocols', 'configures project properties'
  def createRouterProtocols(router, view_controllers, routers)
    @router_name = router

    # Set Protocol Methods
    @router_show_function = ''
    view_controllers.each do |name|
      @router_show_function = @router_show_function + generateViewControllerShowProtocol('ViewController', name)
    end
    routers.each do |name|
      @router_show_function = @router_show_function + generateViewControllerShowProtocol('Router', name)
    end

    # Set Protocol's
    template "templates/template_methods/RouterProtocol.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
    IO.read("templates/template_methods/temp.swift")
  end

  desc 'createRouterShowFunction', 'configures project properties'
  def createRouterShowFunction
    router_to_show = ["Auth","Screen"]

    all_created_methods = ""
    router_to_show.each do |router_name|
      @router_name = router_name
      template "templates/template_methods/ShowRouter.swift", "templates/template_methods/temp.swift", {:force => true, :verbose => false}
      all_created_methods = all_created_methods + IO.read("templates/template_methods/temp.swift")
    end

    all_created_methods
  end
end

CertificateManager.new.init
