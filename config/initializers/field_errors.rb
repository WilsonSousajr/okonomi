# Aponta o campo inválido no próprio campo (#9, #13): aria-invalid para leitores de tela e
# borda vermelha via CSS, em vez do <div class="field_with_errors"> padrão que quebra o layout.
Rails.application.config.action_view.field_error_proc = proc do |html_tag, _instance|
  html_tag.to_str.sub(/\A<(input|textarea|select)\b/, '<\1 aria-invalid="true"').html_safe
end
