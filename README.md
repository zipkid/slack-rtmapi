slack-rtmapi2
=============

As the original author is not reacting i am taking this over under a new namespace.

All you need to use the RTM api of Slack

Please note that this gem is GPLv3. You *CAN'T* use it for proprietary software.
If you need a licence, please contact me and I will respond within the 24 hours.

HOW TO USE
----------

First, install the gem: `gem install slack-rtmapi2`.

```ruby
require 'slack-rtmapi2'

token = 'xxx'
channel_id = 'id'

url = Slack::RtmApi2.get_url token: token # get one on https://api.slack.com/web#basics
client = Slack::RtmApi2::Client.new websocket_url: url

client.on(:message)  { |data| p data }
client.send channel: channel_id, type: 'message', text: 'Hi there'

client.main_loop
assert false # never ending loop
```

As always, pull request welcome.

For more informations about the Slack Real Time API, please check https://api.slack.com/rtm

Contributors
------------
- [mackwic](https://github.com/mackwic)
- [zipkid](https://github.com/zipkid)
