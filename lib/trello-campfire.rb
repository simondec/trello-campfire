#TrelloCampfire
#Parse activity feed events in a campfire room

require 'tinder'
require 'rest_client'

class TrelloCampfire
  #Parse a node from trello
  def self.parse(node, cards)# {{{
    data = node["data"]
    card_id = "[#{data["card"]["id"]}]" if data
    card_name = "[#{data["card"]["name"]}]" if data
    card_object = cards.detect { |card| card["id"] == "#{data["card"]["id"]}" } if data
    card_url = "(#{card_object["url"]})" if data
    creator_fullname = node["memberCreator"]["fullName"] if node["memberCreator"]
    creator_initials = node["memberCreator"]["initials"] if node["memberCreator"]
    member_fullname = node["member"]["fullName"] if node["member"]
    member_initials = node["member"]["initials"] if node["member"]

    # Events handled and parsed in campfire.
    # Change/Comment/Add events to fit your needs.

    # Move card
    if node["type"] == "updateCard" && data["listAfter"] && data["listBefore"]
      return "#{creator_fullname} moved #{card_name} from #{data["listBefore"]["name"]} to #{data["listAfter"]["name"]} #{card_url}"

    # Comment card
    elsif node["type"] == "commentCard"
      return "#{creator_fullname} commented on #{card_name}: \"#{data["text"]}\" #{card_url}"

    # Create card
    elsif node["type"] == "createCard"
      return "#{creator_fullname} created #{card_name} in #{data["list"]["name"]} #{card_url}"

    # Add a member to a card
    elsif node["type"] == "addMemberToCard"
      if node["memberCreator"]["id"] == node["member"]["id"]
        return "#{creator_fullname} joined #{card_name} #{card_url}"
      else
        return "#{creator_fullname} added #{member_fullname} to #{card_name} #{card_url}"
      end

    # Remove a member to a card
    elsif node["type"] == "removeMemberFromCard"
      if node["memberCreator"]["id"] == node["member"]["id"]
        return "#{creator_fullname} left #{card_name} #{card_url}"
      else
        return "#{creator_fullname} removed #{member_fullname} from #{card_name} #{card_url}"
      end

    # Update the name of a card
    elsif node["type"] == "updateCard" && data["old"]
      return "#{creator_fullname} renamed [#{data["old"]["name"]}] to #{card_name} #{card_url}"

    # Complete an item in the checklist of a card
    elsif node["type"] == "updateCheckItemStateOnCard" && data["checkItem"]["state"] == "complete"
      return "#{creator_fullname} completed #{data["checkItem"]["name"]} on #{card_name} #{card_url}"

    end
  end# }}}
end

#Edit the following sections with your own values from Campfire/Trello

#Campfire configuration
campfire = Tinder::Campfire.new 'CAMPFIRE_SITE_NAME', :token => "CAMPFIRE_TOKEN"
campfire_room = campfire.find_room_by_name("CAMPFIRE_ROOM_NAME")

#Trello configuration
#Read the documentation on how to get those values: https://trello.com/docs/gettingstarted/index.html
board_id = "TRELLO_BOARD_ID"
key = "TRELLO_API_KEY"
token = "TRELLO_TOKEN"
actions_url = "https://api.trello.com/1/boards/#{board_id}/actions?limit=10&key=#{key}&token=#{token}"
cards_url = "https://api.trello.com/1/boards/#{board_id}/cards?key=#{key}&token=#{token}"


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

  sleep(60)
end
