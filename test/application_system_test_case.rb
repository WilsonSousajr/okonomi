require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome, screen_size: [ 1400, 1400 ]

  # DEBUG #94 (temporary): light event logger, installed once per browser.
  DEBUG94_INSTALLED = {}
  DEBUG94_SCRIPT = <<~JS
    (function () {
      const buffer = [];
      const prior = (() => { try { return JSON.parse(sessionStorage.getItem("__dbg") || "[]") } catch (e) { return [] } })();
      window.__dbgAll = () => prior.concat(buffer).slice(-300);
      function log(msg) { buffer.push(Math.round(performance.timeOrigin + performance.now()) % 1000000 + " " + location.pathname + " " + msg) }
      function flush() { try { sessionStorage.setItem("__dbg", JSON.stringify(window.__dbgAll())) } catch (e) {} }
      log("NEW DOCUMENT");
      document.addEventListener("DOMContentLoaded", () => log("DOMContentLoaded turbo=" + !!window.Turbo));
      window.addEventListener("load", () => log("load"));
      window.addEventListener("pagehide", () => { log("pagehide"); flush() });
      const detail = e => { const d = e.detail || {}; return [d.url, d.action, d.fetchOptions && d.fetchOptions.method, d.fetchResponse && d.fetchResponse.statusCode, d.success, d.error && String(d.error)].filter(x => x !== undefined && x !== null).join(" ") };
      ["turbo:click","turbo:before-visit","turbo:visit","turbo:before-fetch-request","turbo:before-fetch-response","turbo:fetch-request-error","turbo:submit-start","turbo:submit-end","turbo:before-render","turbo:render","turbo:load","turbo:before-prefetch","turbo:before-cache","turbo:reload"].forEach(n =>
        document.addEventListener(n, e => log(n + " " + detail(e))));
      document.addEventListener("focusin", e => log("focusin " + (e.target.name || e.target.tagName)));
      document.addEventListener("input", e => log("input " + e.target.name + " len=" + e.target.value.length));
      document.addEventListener("submit", e => log("submit " + e.target.action + " prevented=" + e.defaultPrevented), true);
      ["pointerdown","mousedown","click"].forEach(n => document.addEventListener(n, e => log(n + " " + (e.target.tagName + " " + (e.target.textContent || e.target.value || "")).trim().slice(0, 40) + " @" + e.clientX + "," + e.clientY), true));
      document.addEventListener("visibilitychange", () => log("visibility " + document.visibilityState));
    })();
  JS

  if ENV["DEBUG94"]
    setup do
      browser = page.driver.browser
      unless DEBUG94_INSTALLED[browser.object_id]
        browser.execute_cdp("Page.addScriptToEvaluateOnNewDocument", source: DEBUG94_SCRIPT)
        DEBUG94_INSTALLED[browser.object_id] = true
      end
    end
  end

  def before_teardown
    if ENV["DEBUG94"] && !passed?
      puts "\n--- DEBUG LOG #{name} ---"
      puts Array(page.evaluate_script("window.__dbgAll ? window.__dbgAll() : []")).last(150).join("\n")
      puts "--- END DEBUG LOG ---"
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
