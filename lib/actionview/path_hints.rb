module ActionView
  class PathHints
    def initialize(view, template)
      @view = view
      @template = template
    end

    def apply(output_buffer)
      cache_color = cache_hit? ? 'red' : 'green'
      container_style = "position: relative;border:1px solid #{cache_color}!important;"
      label_style = "font-size: 9px;background:beige;position:absolute;top:0px;left:0px;"
      path_hints = "<div style='#{container_style}'>"\
    "<span style='#{label_style}'>#{@template.inspect}</span>"
      output_buffer.prepend(path_hints.html_safe).concat('</div>'.html_safe)
    end

    private

    def cache_hit?
      rails_latest? ?
          @view.view_renderer.cache_hits[@template.virtual_path] :
          @view.view_renderer.lookup_context.cache
    end

    def rails_latest?
      Gem::Version.new(Rails.version) >= Gem::Version.new('5.0.0')
    end
  end

  PartialRenderer.class_eval do
    def render_partial
      path_hints.apply(_render_partial)
    end

    private

    def path_hints
      PathHints.new(@view, @template)
    end

    # If there's a way to call super instead of copypasta let me know.
    # This works for both rails 4 and 5
    def _render_partial
      instrument(:partial) do |payload|
        view, locals, block = @view, @locals, @block
        object, as = @object, @variable

        if !block && (layout = @options[:layout])
          layout = find_template(layout.to_s, @template_keys)
        end

        object = locals[as] if object.nil? # Respect object when object is false
        locals[as] = object if @has_object

        content = @template.render(view, locals) do |*name|
          view._layout_for(*name, &block)
        end

        content = layout.render(view, locals) { content } if layout
        content
      end
    end
  end
end