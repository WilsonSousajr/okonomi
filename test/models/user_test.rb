require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "downcases and strips email_address" do
    user = User.new(email_address: " DOWNCASED@EXAMPLE.COM ")
    assert_equal("downcased@example.com", user.email_address)
  end

  test "accepts a valid e-mail and a password of 8 characters" do
    assert User.new(email_address: "nova@example.com", password: "12345678").valid?
  end

  test "rejects an invalid e-mail format" do
    [ "abc", "a@", "@example.com", "" ].each do |email|
      user = User.new(email_address: email, password: "12345678")

      assert_not user.valid?, "#{email.inspect} should be rejected"
      assert user.errors.of_kind?(:email_address, email.empty? ? :blank : :invalid)
    end
  end

  test "rejects a password shorter than 8 characters (#2)" do
    user = User.new(email_address: "nova@example.com", password: "1234567")

    assert_not user.valid?
    assert user.errors.of_kind?(:password, :too_short)
  end

  test "rejects a password longer than bcrypt's 72 bytes (#2)" do
    user = User.new(email_address: "nova@example.com", password: "a" * 73)

    assert_not user.valid?
  end

  test "explains the 72-byte limit in Portuguese for accented passwords issue_81" do
    user = User.new(email_address: "nova@example.com", password: "ã" * 40)

    assert_not user.valid?
    message = user.errors.full_messages_for(:password).first
    assert_equal "Senha é muito longa (máximo: 72 bytes; letras acentuadas contam como 2)", message
  end

  test "rejects a duplicate e-mail regardless of case and padding (#2)" do
    user = User.new(email_address: " ONE@Example.com ", password: "12345678")

    assert_not user.valid?
    assert_includes user.errors.full_messages, "E-mail já está cadastrado"
  end

  test "stores the password as a digest, never in plain text (#2)" do
    user = User.create!(email_address: "digest@example.com", password: "segredo-forte")

    assert_not_includes User.column_names, "password"
    assert_match(/\A\$2a\$/, user.reload.password_digest)
    assert_not_includes user.password_digest, "segredo-forte"
  end
end
