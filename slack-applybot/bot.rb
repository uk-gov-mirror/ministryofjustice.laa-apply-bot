module SlackApplybot
  class Bot < SlackRubyBot::Bot
    COMMANDS = [
      {
        name: 'add users',
        desc: '`@apply-bot add users <comma separated names>`',
        long_desc: <<~ADDUSER.chomp
          Generates a portal user script in the #{ENV['USER_OUTPUT_CHANNEL']} channel regardless of where you ask
          e.g. `@applybot add user BENREID` or `@applybot add users benreid, NEETADESOR`
        ADDUSER
      },
      {
        name: 'ages',
        desc: '`@apply-bot ages`',
        long_desc: 'Shows the time since both applications were last deployed'
      },
      {
        name: 'details',
        desc: '`@apply-bot <application> details <environment>` e.g. `@apply-bot cfe details staging`',
        long_desc: 'Shows the ping details page for the selected application and non-uat environments, '\
                   'e.g.  `@apply-bot apply details staging` or `@apply-bot cfe details production`'
      },
      {
        name: 'run tests',
        desc: '`@apply-bot run tests`',
        long_desc: <<~RUNTESTS.chomp
          Starts a remote test run on the linked github repo it will respond to you with a link
          to the running job on github.  When the job finishes it will message you with the result
        RUNTESTS
      },
      {
        name: 'uat urls',
        desc: '`@apply-bot uat urls`',
        long_desc: 'Returns a list of all Apply UAT urls currently available'
      },
      {
        name: 'uat url',
        desc: '`@apply-bot uat url <branch> e.g. @apply-bot uat url ap-999`',
        long_desc: 'This will either show the uat url for the specified branch or, if it cannot be matched,'\
                   'return an apology and the list of all available uat environments'
      },
      {
        name: 'helm',
        desc: '`@apply-bot helm <instruction>` e.g. `@apply-bot helm list`',
        long_desc: 'This will run a helm command against the UAT helm kubernetes cluster ' \
                   'currently supported instructions are: `list`, `tidy` & `delete` ' \
                   'delete will need to be followed by a 2fa code, see `help 2fa`'
      },
      {
        name: 'github',
        desc: '`@apply-bot github <instruction>` e.g. `@apply-bot github link <your github name>`',
        long_desc: 'This will run a command that links your current slack account ' \
                     'with a github account, currently supported instruction is: `link`'
      },
      {
        name: '2fa',
        desc: '`@apply-bot 2fa <instruction>` e.g. `@apply-bot 2fa setup`',
        long_desc: 'This will enable two-factor authentication for you to issue potentially ' \
                   'destructive commands, currently supported instructions are: `setup`, `confirm`'
      }
    ].freeze

    help do
      title 'LAA Apply Bot'
      desc 'This bot assists the LAA Apply team to administer their applications'

      COMMANDS.each do |command|
        command command[:name] do
          desc command[:desc]
          long_desc command[:long_desc]
        end
      end
    end
  end
end
