#-*- coding: utf-8 -*-

# 自分のツイートをRTしたユーザのその後5分間ツイートを監視

Plugin.create :retweet_user_tl do
  @retweet_users = {}

  tab(:retweet_user_tl, "自分のツイートをRTしたユーザ") do
    set_icon File.expand_path(File.join(File.dirname(__FILE__), 'icon.png'))
    timeline :retweet_user_tl
  end

  on_retweet do |retweets|
    retweets.each do |message|
      if message.retweet_source.user.id == User.findbyidname(Service.primary.user).id
        @retweet_users[message.user.id] = Time.now 
      end
    end
  end

  on_appear do |messages|
    messages.each do |message|
      timeline(:retweet_user_tl) << message if @retweet_users[message.user.id]
    end
  end

  on_period do
    @retweet_users.each do |id, time|
      Service.primary.user_timeline(user_id: id, include_rts: 1, count: [UserConfig[:profile_show_tweet_once], 200].min)
    end
    @retweet_users.delete_if do |id, time|
      Time.now - time >= 600
    end
  end
  
end

