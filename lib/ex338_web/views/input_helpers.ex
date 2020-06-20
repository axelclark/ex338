defmodule Ex338Web.InputHelpers do
  use Phoenix.HTML

  def input(form, field, opts \\ []) do
    type = opts[:using] || Phoenix.HTML.Form.input_type(form, field)

    wrapper_class = opts[:wrapper_class] || ""
    label_class = opts[:label_class] || ""
    input_class = opts[:input_class] || ""

    wrapper_opts = [class: "form-group #{state_class(form, field)} #{wrapper_class}"]
    label_opts = [class: "control-label #{label_class}"]
    input_opts = [class: "form-control #{input_class}"]

    input_opts = maybe_add_select_options(type, input_opts, opts)

    content_tag :div, wrapper_opts do
      label = build_label(form, field, label_opts, opts)
      input = input(type, form, field, input_opts)
      error = Ex338Web.ErrorHelpers.error_tag(form, field) || ""
      [label, input, error]
    end
  end

  # Helpers

  # input

  def build_label(form, field, label_opts, opts) do
    if opts[:label] == false do
      content_tag(:div, "")
    else
      label(form, field, humanize(field), label_opts)
    end
  end

  defp input(:select, form, field, input_opts) do
    {options, input_opts} = Keyword.pop(input_opts, :select_options)
    apply(Phoenix.HTML.Form, :select, [form, field, options, input_opts])
  end

  defp input(type, form, field, input_opts) do
    apply(Phoenix.HTML.Form, type, [form, field, input_opts])
  end

  defp maybe_add_select_options(:select, input_opts, opts) do
    options = opts[:select_options] || []
    input_opts = Keyword.put(input_opts, :select_options, options)

    case opts[:prompt] do
      nil -> input_opts
      prompt -> Keyword.put(input_opts, :prompt, prompt)
    end
  end

  defp maybe_add_select_options(_type, input_opts, _opts), do: input_opts

  defp state_class(form, field) do
    cond do
      # The form was not yet submitted
      !form.source.action -> ""
      form.errors[field] -> "has-error"
      true -> "has-success"
    end
  end
end
