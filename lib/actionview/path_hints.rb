module ActionView
  class PathHints
    CONTAINER = %w(
      position:relative
      border:1px\ solid\ %s
    )
    LABEL = %w(
      font-size:9px
      background:beige
      position:absolute
      top:0
      left:0
    )
    def initialize(view, template)
      @view = view
      @template = template
    end

    def apply(output_buffer)
      output_buffer.prepend("<div style='#{sprintf(styles(CONTAINER), cached? ? 'green' : 'red')}'>"\
    "<span style='#{styles(LABEL)}'>#{@template.inspect}</span>".html_safe).concat('</div>'.html_safe)
    end

    private

    def styles(values)
      values.each { |value| "#{value}!important;" }.join
    end

    def cached?
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