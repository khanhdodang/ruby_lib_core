require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/android/webdriver/w3c/actions_test.rb
class AppiumLibCoreTest
  module Android
    module WebDriver
      module MJSONWP
        class ActionsTest < Minitest::Test
          include AppiumLibCoreTest::Mock

          def setup
            @core ||= ::Appium::Core.for(Caps.android)
            @driver ||= android_mock_create_session_w3c
          end

          def test_press_touch_action
            action = Appium::Core::TouchAction.new(@driver).press(
              element: ::Selenium::WebDriver::Element.new(@driver.send(:bridge), 'id')
            ).release

            assert_equal [{ action: :press, options: { element: 'id' } }, { action: :release }], action.actions

            stub_request(:post, "#{SESSION}/touch/perform")
              .with(body: { actions: [{ action: :press, options: { element: 'id' } }, { action: :release }] }.to_json)
              .to_return(headers: HEADER, status: 200, body: { value: nil }.to_json)

            action.perform
            assert_equal [], action.actions
          end
        end # class CommandsTest
      end # module W3C
    end # module WebDriver
  end # module Android
end # class AppiumLibCoreTest
