require 'test_helper'
require 'webmock/minitest'

# $ rake test:unit TEST=test/unit/common_test.rb
class AppiumLibCoreTest
  class Common
    class AppiumCoreBaseBridgeTest < Minitest::Test
      include AppiumLibCoreTest::Mock

      def setup
        @bridge = Appium::Core::Base::Bridge.new
      end

      RESPONSE_BASE_VALUE = {
        sessionId: '1234567890',
        capabilities: {
          platformName: :android,
          automationName: 'uiautomator2',
          app: 'test/functional/app/api.apk.zip',
          platformVersion: '7.1.1',
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis'
        }
      }.freeze

      CAPS = {
        platformName: :android,
        automationName: 'uiautomator2',
        app: "#{Dir.pwd}/test/functional/app/api.apk.zip",
        platformVersion: '7.1.1',
        deviceName: 'Android Emulator',
        appPackage: 'io.appium.android.apis'
      }.freeze

      APPIUM_PREFIX_CAPS = {
        platformName: :android,
        'appium:automationName' => 'uiautomator2',
        'appium:app' => "#{Dir.pwd}/test/functional/app/api.apk.zip",
        'appium:platformVersion' => '7.1.1',
        'appium:deviceName' => 'Android Emulator',
        'appium:appPackage' => 'io.appium.android.apis'
      }.freeze

      def test_create_session_force_mjsonwp
        response = {
          status: 0, # To make bridge.dialect == :oss
          value: RESPONSE_BASE_VALUE
        }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { desiredCapabilities: CAPS }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts/implicit_wait")
          .with(body: { ms: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        driver = ::Appium::Core.for({ caps: CAPS.merge({ forceMjsonwp: true }), appium_lib: {} }).start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts/implicit_wait", body: { ms: 0 }.to_json, times: 1)
        driver
      end

      def test_create_session_force_mjsonwp_false
        response = { value: RESPONSE_BASE_VALUE }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { desiredCapabilities: CAPS,
                        capabilities: { firstMatch: [APPIUM_PREFIX_CAPS] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts")
          .with(body: { implicit: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        driver = ::Appium::Core.for({ caps: CAPS.merge({ forceMjsonwp: false }), appium_lib: {} }).start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)
        driver
      end

      def test_create_session_force_mjsonwp_with_source_package
        response = {
          status: 0, # To make bridge.dialect == :oss
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: 'uiautomator2',
              app: 'sauce-storage:test/functional/app/api.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis'
            }
          }
        }.to_json
        http_caps = {
          platformName: :android,
          automationName: 'uiautomator2',
          app: 'sauce-storage:test/functional/app/api.apk.zip',
          platformVersion: '7.1.1',
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis'
        }

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { desiredCapabilities: http_caps }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts/implicit_wait")
          .with(body: { ms: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        core = ::Appium::Core.for({ caps: http_caps.merge({ forceMjsonwp: true }), appium_lib: {} })
        core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts/implicit_wait", body: { ms: 0 }.to_json, times: 1)

        assert_equal 'sauce-storage:test/functional/app/api.apk.zip', core.caps[:app]
      end

      def test_create_session_w3c
        response = { value: RESPONSE_BASE_VALUE }.to_json

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { desiredCapabilities: CAPS,
                        capabilities: { firstMatch: [APPIUM_PREFIX_CAPS] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts")
          .with(body: { implicit: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        driver = ::Appium::Core.for({ caps: CAPS, appium_lib: {} }).start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)
        driver
      end

      def test_create_session_w3c_with_http_package
        response = {
          value: {
            sessionId: '1234567890',
            capabilities: {
              platformName: :android,
              automationName: 'uiautomator2',
              app: 'http://example.com/test.apk.zip',
              platformVersion: '7.1.1',
              deviceName: 'Android Emulator',
              appPackage: 'io.appium.android.apis'
            }
          }
        }.to_json
        http_caps = {
          platformName: :android,
          automationName: 'uiautomator2',
          app: 'http://example.com/test.apk.zip',
          platformVersion: '7.1.1',
          deviceName: 'Android Emulator',
          appPackage: 'io.appium.android.apis'
        }

        appium_prefix_http_caps = {
          platformName: :android,
          'appium:automationName' => 'uiautomator2',
          'appium:app' => 'http://example.com/test.apk.zip',
          'appium:platformVersion' => '7.1.1',
          'appium:deviceName' => 'Android Emulator',
          'appium:appPackage' => 'io.appium.android.apis'
        }

        stub_request(:post, 'http://127.0.0.1:4723/wd/hub/session')
          .with(body: { desiredCapabilities: http_caps,
                        capabilities: { firstMatch: [appium_prefix_http_caps] } }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: response)

        stub_request(:post, "#{Mock::SESSION}/timeouts")
          .with(body: { implicit: 0 }.to_json)
          .to_return(headers: Mock::HEADER, status: 200, body: { value: nil }.to_json)

        core = ::Appium::Core.for({ caps: http_caps, appium_lib: {} })
        core.start_driver

        assert_requested(:post, 'http://127.0.0.1:4723/wd/hub/session', times: 1)
        assert_requested(:post, "#{Mock::SESSION}/timeouts", body: { implicit: 0 }.to_json, times: 1)

        assert_equal 'http://example.com/test.apk.zip', core.caps[:app]
      end

      def test_add_appium_prefix_compatible_with_oss
        cap = {
          platformName: :ios,
          automationName: 'XCUITest',
          app: 'test/functional/app/UICatalog.app.zip',
          platformVersion: '11.4',
          deviceName: 'iPhone Simulator',
          useNewWDA: true,
          some_capability1: 'some_capability1',
          someCapability2: 'someCapability2',
          'moz:someOtherCap' => 'someOtherCap' # Should ignore if it already have some extentions
        }
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)

        expected = {
          proxy: nil,
          platformName: :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          'appium:platformVersion' => '11.4',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability1' => 'some_capability1',
          'appium:someCapability2' => 'someCapability2',
          'moz:someOtherCap' => 'someOtherCap'
        }

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end

      def test_add_appium_prefix_already_have_appium_prefix
        cap = {
          platformName: :ios,
          automationName: 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          platformVersion: '11.4',
          deviceName: 'iPhone Simulator',
          useNewWDA: true,
          some_capability1: 'some_capability1',
          someCapability2: 'someCapability2'
        }
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)

        expected = {
          proxy: nil,
          platformName: :ios,
          'appium:automationName' => 'XCUITest',
          'appium:app' => 'test/functional/app/UICatalog.app.zip',
          'appium:platformVersion' => '11.4',
          'appium:deviceName' => 'iPhone Simulator',
          'appium:useNewWDA' => true,
          'appium:some_capability1' => 'some_capability1',
          'appium:someCapability2' => 'someCapability2'
        }

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end

      def test_add_appium_prefix_has_no_parameter
        cap = {}
        base_caps = Appium::Core::Base::Capabilities.create_capabilities(cap)
        expected = { proxy: nil }

        assert_equal expected, @bridge.add_appium_prefix(base_caps).__send__(:capabilities)
      end
    end
  end
end
