module MCollective
  module Test
    class LocalAgentTest
      class << self
      end
      include RSpec::Mocks
      # include RSpec::Mocks::Methods
      include RSpec::Mocks::AnyInstance
      include RSpec::Mocks::ExampleMethods
      # RSpec::Mocks.setup(self)

      attr_reader :config, :logger, :agent, :connector, :plugin, :facts

      include Test::Util

      def initialize(agent, options={})
        config = options[:config]

        facts = options[:facts] || {"fact" => "value"}

        @config = create_config_mock(config)
        @agent = agent.to_s
        @logger = create_logger_mock
        @connector = create_connector_mock
        @plugin = load_agent(agent, options[:agent_file])

        create_facts_mock(facts)
        mock_validators

        make_call_helper
      end


      # Place the mocked connector into the plugin instance and
      # create a call helper method that passes the connector in
      # and call the action via handlemsg.
      #
      # This will let you test auditing etc
      def make_call_helper
        @plugin.instance_variable_set("@mocked_connector", @connector)

        @plugin.instance_eval "
          def call(action, args={})
              request = {:action => action.to_s,
                         :agent => '#{@agent}',
                         :data => args}

              handlemsg({:body => request}, @mocked_connector)
          end
        "
      end
    end
  end
end
