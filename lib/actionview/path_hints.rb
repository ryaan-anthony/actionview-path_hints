module ActionView
  class PathHints
    def self.apply(view, template, output_buffer)
      cache_hit = view.view_renderer.cache_hits[template.virtual_path]
      cache_color = cache_hit.nil? ? 'red' : 'green'
      container_style = "position: relative;border:1px solid #{cache_color}!important;"
      label_style = "font-size: 9px;background:beige;position:absolute;top:0px;left:0px;"
      path_hints = "<div style='#{container_style}'>"\
    "<span style='#{label_style}'>#{template.inspect}</span>"
      output_buffer.prepend(path_hints.html_safe).concat('</div>'.html_safe)
    end
  end

  PartialRenderer.class_eval do
    def render_partial
      PathHints.apply(@view, @template, _render_partial)
    end

    private

    # If there's a way to call super instead of copypasta let me know.
    # pulled from actionview-5.1.6/lib/action_view/renderer/partial_renderer.rb:330
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
        payload[:cache_hit] = view.view_renderer.cache_hits[@template.virtual_path]
        content
      end
    end
  end
end