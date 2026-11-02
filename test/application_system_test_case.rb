require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # DEBUG #94 (temporary): slow the renderer like a busy CI runner.
  if ENV["DEBUG94"]
    setup do
      visit "about:blank"
      page.driver.browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: <<~JS)
        (function () {
          const t0 = performance.timeOrigin;
          function log(msg) {
            try {
              const l = JSON.parse(sessionStorage.getItem("__dbg") || "[]");
              l.push(Math.round(performance.now() + t0) % 100000 + " " + location.pathname + " " + msg);
              sessionStorage.setItem("__dbg", JSON.stringify(l));
            } catch (e) {}
          }
          log("NEW DOCUMENT readyState=" + document.readyState);
          document.addEventListener("DOMContentLoaded", () => log("DOMContentLoaded turbo=" + !!window.Turbo));
          window.addEventListener("load", () => log("load turbo=" + !!window.Turbo));
          ["turbo:click","turbo:before-visit","turbo:visit","turbo:before-fetch-request","turbo:before-fetch-response","turbo:submit-start","turbo:submit-end","turbo:before-render","turbo:render","turbo:load","turbo:fetch-request-error","turbo:before-prefetch","turbo:before-cache"].forEach(n =>
            document.addEventListener(n, e => log(n + " " + (e.detail && (e.detail.url || (e.detail.fetchOptions && e.detail.fetchOptions.method) || "") || ""))));
          document.addEventListener("focusin", e => log("focusin " + (e.target.name || e.target.tagName)));
          document.addEventListener("input", e => log("input " + e.target.name + "=" + JSON.stringify(e.target.value)));
          document.addEventListener("submit", e => log("submit " + (e.target.action || "") + " defaultPrevented=" + e.defaultPrevented), true);
          document.addEventListener("click", e => log("click " + (e.target.textContent || e.target.value || e.target.tagName).trim().slice(0, 30)), true);
          window.addEventListener("pagehide", () => log("pagehide"));
        })();
      JS
    end

  end

  def before_teardown
    if ENV["DEBUG94"] && !passed?
      puts "\n--- DEBUG LOG #{name} ---"
      puts Array(page.evaluate_script("JSON.parse(sessionStorage.getItem('__dbg') || '[]')")).join("\n")
    end
    super
  end

  # Signs in the way a user does, so system tests exercise the real form (#3).
  def sign_in_through_form(user, password: "password")
    visit new_session_path
    fill_in "E-mail", with: user.email_address
    fill_in "Senha", with: password
    click_button "Entrar"
  end
end
