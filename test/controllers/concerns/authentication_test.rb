require "test_helper"

# Regressão de #40: o cookie de sessão era gravado sem a flag `secure`, então em
# produção podia trafegar em HTTP puro e ser lido por quem estivesse no caminho
# da rede — sequestro de sessão sem precisar da senha.
class AuthenticationTest < ActiveSupport::TestCase
  # Expõe o método privado do concern sem passar por uma requisição, para que o
  # teste fale sobre a decisão em si e não sobre o roteamento.
  class Controller < ApplicationController
    def call_session_cookie_options(session) = session_cookie_options(session)
  end

  setup { @session = Struct.new(:id).new(123) }

  test "cookie de sessão é marcado secure em produção (#40)" do
    with_env "production" do
      assert session_cookie_options[:secure],
        "o cookie de sessão precisa da flag secure em produção"
    end
  end

  test "cookie de sessão não é secure em desenvolvimento (#40)" do
    with_env "development" do
      assert_not session_cookie_options[:secure],
        "exigir secure fora de produção quebraria o desenvolvimento local em HTTP"
    end
  end

  test "cookie de sessão é httponly e same_site lax em qualquer ambiente (#40)" do
    options = session_cookie_options

    assert options[:httponly], "o cookie não deve ser legível por JavaScript"
    assert_equal :lax, options[:same_site]
    assert_equal 123, options[:value]
  end

  private
    def session_cookie_options = Controller.new.call_session_cookie_options(@session)

    def with_env(name)
      original = Rails.env
      Rails.env = name
      yield
    ensure
      Rails.env = original
    end
end
