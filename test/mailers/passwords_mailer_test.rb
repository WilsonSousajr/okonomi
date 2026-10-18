require "test_helper"

# O e-mail de redefinição também segue a interface em português (#1).
class PasswordsMailerTest < ActionMailer::TestCase
  test "reset e-mail is written in Portuguese" do
    mail = PasswordsMailer.reset(users(:one))

    assert_equal "Redefina sua senha do okonomi", mail.subject
    assert_match "Este link expira em 15 minutos", mail.text_part.body.to_s
    assert_no_match(/translation missing/i, mail.html_part.body.to_s)
  end
end
