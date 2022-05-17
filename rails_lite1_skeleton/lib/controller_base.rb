require 'active_support'
require 'active_support/core_ext'
require 'erb'
require_relative './session'

class ControllerBase
  attr_reader :req, :res, :params

  # Setup the controller
  def initialize(req, res)
    @req = req
    @res = res
    @already_built_response = false
  end

  # Helper method to alias @already_built_response
  def already_built_response?
    @already_built_response
  end

  # Set the response status code and header
  def redirect_to(url)
    if @already_built_response
      raise "Double render error"
    else
      @already_built_response = true
      @res.status = 302
      @res["Location"] = url
      nil
    end
  end

  # Populate the response with content.
  # Set the response's content type to the given type.
  # Raise an error if the developer tries to double render.
  def render_content(content, content_type)
    if @already_built_response
      raise "Double render error"
    else
      @already_built_response = true
      @res.write(content)
      @res["Content-Type"] = content_type
      nil
    end
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    tpath = File.dirname(__FILE__)
    tpath = File.join(tpath, "..", "views", 
      self.class.name.underscore, "#{template_name}.html.erb")
    # template = File.read("views/#{controller_name}/#{template_name}.html.erb")
    template = File.read(tpath)
    content = ERB.new(template).result(binding)
    render_content(content, "text/html")
  end

  # method exposing a `Session` object
  def session
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
  end
end

