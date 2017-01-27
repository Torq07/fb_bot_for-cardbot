require 'json'
include Facebook::Messenger

class CardBot

  attr_accessor :sender, :payload

  def initialize(sender, payload)
    @sender = sender
    @payload = payload
  end

  def check_code(code)
     user = Customer.find_by(activation_code:code)
    if user
      user.update_attribute(:fb_id, sender['id'])
      Bot.deliver(
        recipient: sender,
        message: {
          text: 'Thank you. Your code accepted and now you can use out FB bot'
        }
      )
    else
      Bot.deliver(
        recipient: sender,
        message: {
          text: 'Sorry we didn\'t find user with provided activation code'
        }
      )
    end  
    
  end

  def details
    card = Card.find(payload['card_id'])
    user = Customer.find(payload['user_id'])   
    Bot.deliver(
      recipient: sender,
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: [
              {
                "title":"Owner: #{user.first_name.capitalize} #{user.last_name.capitalize}",
                "image_url":"https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcTQ2MSw4c0fEkLZaDAwt4qdbxWEAKG0lv9JyqXj4pSWw0_KXLZbyQ",
                "subtitle":"Card balance: #{card.balance} \n Expiration date: #{card.expiring_date}",
                "buttons":[
                  {
                    type:"postback",
                    title:"Show all cards",
                    payload:{
                      id:"show_cards",
                      value: user.id
                    }.to_json
                  },
                  {
                    "type":"postback",
                    "title":"I'm not intresting",
                    "payload":"end_chat"
                  }  
                ]
              }              
            ]
          }
        }
      }
    )
  end

  def end_chat
      Bot.deliver(
        recipient: sender,
        message: {
          text: 'Bye! see you another time'
        }
      )
  end

  def request_activation_code
    text = 'Hello, you need to activate your account with '+
           'your activation code received from seller. '+
           'Please enter: "Code: {Your activation code}"'
    Bot.deliver(
      recipient: sender,
      message: {
        text: text
      }
    )
  end

  def show_cards(user_id)
    user = Customer.find(user_id)
    buttons = user.cards.order(:id).map do |card|
      {
        type: 'postback',
        title: "#{card.id} #{card.status}",
        payload: {
          id: 'details',
          card_id: card.id,
          user_id: user.id
        }.to_json
      }
    end
    if !buttons.empty?
      text = 'Here is your card'
      text+='s' if buttons.count>1
      Bot.deliver(
        recipient: sender,
        message: {
          attachment: {
            type: 'template',
            payload: {
              template_type: 'button',
              text: text,
              buttons: buttons
            }
          }
        }
      )
    else
      text = 'Sorry you don\'t have any cards assigned for your account'
      Bot.deliver(
        recipient: sender,
        message: {
          text: text
        }
      )
    end 
  end

  # def suggest

    #   Bot.deliver(
    #     recipient: sender,
    #     message: {
    #       text: "Here is information about your card"
    #     }
    #   )

    #   elements = products.map do |product|
    #     {
    #       title: product.name,
    #       subtitle: product.name,
    #       image_url: product.image,
    #       buttons: [
    #         {
    #           type: 'postback',
    #           title: 'Buy',
    #           payload: {
    #             id: 'buy',
    #             product_id: product.id,
    #             product_name: product.name,
    #             product_image: product.image
    #           }.to_json
    #         },
    #         {
    #           type: 'postback',
    #           title: 'Not interested!',
    #           payload: 'end_chat'
    #         }
    #       ]
    #     }
    #   end

    #   Bot.deliver(
    #     recipient: sender,
    #     message: {
    #       attachment: {
    #         type: 'template',
    #         payload: {
    #           template_type: 'generic',
    #           elements: elements.to_json
    #         }
    #       }
    #     }
    #   )
  # end
end

def get_sender_profile(sender)
  request = HTTParty.get(
    "https://graph.facebook.com/v2.6/#{sender['id']}",
    query: {
      access_token: ENV['ACCESS_TOKEN'],
      fields: 'first_name,last_name,gender,profile_pic'
    }
  )

  request.parsed_response
end

def valid?(json)
  JSON.parse(json)
  return true
rescue StandardError
  return false
end

Bot.on :message do |message|
  user = Customer.find_by(fb_id:message.sender['id'])
  message.text[/code:?\s*(\d+)/i]
  bot = CardBot.new(message.sender, message.text)
  code = $1
  if code
    bot.check_code(code)
  elsif user 
    puts "Sender ID: #{message.sender['id']}"
    sender = get_sender_profile(message.sender)
    puts "*************************"
    puts sender.inspect
    puts "*************************"
    bot.show_cards(user.id)
  else  
    bot.request_activation_code
  end  
end

Bot.on :postback do |postback|
  payload = postback.payload
  parsed_payload = valid?(payload) ? JSON.parse(payload) : payload

  bot = CardBot.new(postback.sender, parsed_payload)

  if parsed_payload && parsed_payload['id']
    value = parsed_payload['value']
    if value
      bot.send(parsed_payload['id'].to_sym,value)
    else 
      bot.send(parsed_payload['id'])
    end  
  else
    bot.send(parsed_payload)
  end
end
