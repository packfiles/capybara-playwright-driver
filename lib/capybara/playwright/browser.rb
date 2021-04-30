module Capybara
  module Playwright
    class Browser
      def self.undefined_method(name)
        define_method(name) do |*args, **kwargs|
          puts "call #{name}(args=#{args}, kwargs=#{kwargs})"
          raise NotImplementedError.new("Capybara::Playwright::Browser##{name} is not implemented!")
        end
      end

      def initialize(playwright:, driver:, browser_type:, browser_options:, page_options:)
        @driver = driver

        browser = playwright.send(browser_type).launch(**browser_options)

        page = browser.new_page(**page_options)

        @playwright_browser = browser
        @playwright_page = page
      end

      def quit
        @playwright_browser.close
      end

      undefined_method :current_url

      def visit(path)
        url =
          if Capybara.app_host
            URI(Capybara.app_host).merge(path)
          elsif Capybara.default_host
            URI(Capybara.default_host).merge(path)
          else
            path
          end

        @playwright_page.goto(url)
      end

      def refresh
        @playwright_page.evaluate('() => { location.reload(true) }')
      end

      def find_xpath(query, **options)
        @playwright_page.wait_for_selector(
          "xpath=#{query}",
          state: :visible,
          timeout: Capybara.default_max_wait_time * 1000,
        )
        @playwright_page.query_selector_all("xpath=#{query}").map do |el|
          Node.new(@driver, @puppeteer_page, el)
        end
      end

      def find_css(query, **options)
        @playwright_page.wait_for_selector(
          query,
          state: :visible,
          timeout: Capybara.default_max_wait_time * 1000,
        )
        @playwright_page.query_selector_all(query).map do |el|
          Node.new(@driver, @playwright_page, el)
        end
      end

      undefined_method :html
      undefined_method :go_back
      undefined_method :go_forward
      undefined_method :execute_script
      undefined_method :evaluate_script
      undefined_method :evaluate_async_script

      def save_screenshot(path, **options)
        @playwright_page.screenshot(path: path)
      end

      undefined_method :response_headers
      undefined_method :status_code
      undefined_method :send_keys
      undefined_method :switch_to_frame
      undefined_method :current_window_handle
      undefined_method :window_size
      undefined_method :resize_window_to
      undefined_method :maximize_window
      undefined_method :fullscreen_window
      undefined_method :close_window
      undefined_method :window_handles
      undefined_method :open_new_window
      undefined_method :switch_to_window
      undefined_method :no_such_window_error
      undefined_method :accept_modal
      undefined_method :dismiss_modal
    end
  end
end
