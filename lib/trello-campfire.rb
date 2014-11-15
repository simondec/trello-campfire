require 'time'
require 'tinder'
require 'rest_client'
require 'trollop'

class TrelloCampfire
  #Parse a node from trello
  def self.parse(node, cards)# {{{
    data = node["data"]
    if data && data['card']
      card_id = "[#{data["card"]["id"]}]"
      card_name = "[#{data["card"]["name"]}]"
      card_object = cards.detect { |card| card["id"] == "#{data["card"]["id"]}" }
    end

    card_url = "(#{card_object["url"]})" if data && data['card']
    creator_fullname = node["memberCreator"]["fullName"] if node["memberCreator"]
    creator_initials = node["memberCreator"]["initials"] if node["memberCreator"]
    member_fullname = node["member"]["fullName"] if node["member"]
    member_initials = node["member"]["initials"] if node["member"]

    # Events handled and parsed in campfire.
    # Change/Comment/Add events to fit your needs.

    prefix = "trello"

    # Move card
    if node["type"] == "updateCard" && data["listAfter"] && data["listBefore"]
      return "[#{prefix}] #{creator_fullname} moved #{card_name} from #{data["listBefore"]["name"]} to #{data["listAfter"]["name"]} #{card_url}"

    # Comment card
    elsif node["type"] == "commentCard"
      return "[#{prefix}] #{creator_fullname} commented on #{card_name}: \"#{data["text"]}\" #{card_url}"

    # Create card
    elsif node["type"] == "createCard"
      return "[#{prefix}] #{creator_fullname} created #{card_name} in #{data["list"]["name"]} #{card_url}"

    # Add a member to a card
    elsif node["type"] == "addMemberToCard"
      if node["memberCreator"]["id"] == node["member"]["id"]
        return "[#{prefix}] #{creator_fullname} joined #{card_name} #{card_url}"
      else
        return "[#{prefix}] #{creator_fullname} added #{member_fullname} to #{card_name} #{card_url}"
      end

    # Remove a member to a card
    elsif node["type"] == "removeMemberFromCard"
      if node["memberCreator"]["id"] == node["member"]["id"]
        return "[#{prefix}] #{creator_fullname} left #{card_name} #{card_url}"
      else
        return "[#{prefix}] #{creator_fullname} removed #{member_fullname} from #{card_name} #{card_url}"
      end

    # Update the name of a card
    elsif node["type"] == "updateCard" && data["old"] && data["old"]["name"]
      return "[#{prefix}] #{creator_fullname} renamed [#{data["old"]["name"]}] to #{card_name} #{card_url}"

    # archived card
    elsif node["type"] == "updateCard" && data["old"]
      if data["old"]["closed"] == true
        return "[#{prefix}] #{creator_fullname} un-archived #{card_name} #{card_url}"
      elsif data["old"]["closed"] == false
        return "[#{prefix}] #{creator_fullname} archived #{card_name}"
      end

    # Complete an item in the checklist of a card
    elsif node["type"] == "updateCheckItemStateOnCard" && data["checkItem"]["state"] == "complete"
      return "[#{prefix}] #{creator_fullname} completed #{data["checkItem"]["name"]} on #{card_name} #{card_url}"

    end
  end# }}}
end

opts = Trollop::options do
  opt :campfire_subdomain, "Campfire Subdomain", :required => true, :type => String
  opt :campfire_token, "Campfire API Token", :required => true, :type => String
  opt :campfire_room_name, "Campfire Room Name", :required => true, :type => String
  opt :trello_board_id, "Trello Board Id", :required => true, :type => String
  opt :trello_api_key, "Trello API Key", :required => true, :type => String
  opt :trello_api_token, "Trello API Token", :required => true, :type => String
  opt :update_interval, "Update Interval (in seconds)", :default => 30
end

#Campfire configuration
campfire = Tinder::Campfire.new opts[:campfire_subdomain], :token => opts[:campfire_token]
campfire_room = campfire.find_room_by_name(opts[:campfire_room_name])

#Trello configuration
#Read the documentation on how to get those values: https://trello.com/docs/gettingstarted/index.html
actions_url = "https://api.trello.com/1/boards/#{opts[:trello_board_id]}/actions?limit=10&key=#{opts[:trello_api_key]}&token=#{opts[:trello_api_token]}"
cards_url = "https://api.trello.com/1/boards/#{opts[:trello_board_id]}/cards?key=#{opts[:trello_api_key]}&token=#{opts[:trello_api_token]}"


@last_index = nil
@last_date = nil

while true do
  parsed_respond = JSON.parse(RestClient.get(actions_url))

  ids = parsed_respond.collect { |response| response["id"] }

  if @last_date
    parsed_respond.each_with_index do |response, i|
      response_date = Time.parse(response["date"])
      @last_index = i
      break if response_date <= @last_date
    end

    i = @last_index - 1

    if i >= 0
      parsed_cards = JSON.parse(RestClient.get(cards_url))

      while i >= 0
        campfire_room.speak(TrelloCampfire.parse(parsed_respond[i], parsed_cards))
        i = i - 1
      end
    end

    @last_date = Time.parse(parsed_respond[0]["date"])
  else
    @last_date = Time.now.utc
  end

  sleep(opts[:update_interval])
end
