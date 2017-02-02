require 'json'
require "#{Rails.root}/lib/assets/twillo"
include Facebook::Messenger

class CardBot

  attr_accessor :sender, :payload

  def initialize(sender, payload)
    @sender = sender
    @payload = payload
    @url = 'https://b392afe7.ngrok.io'
    @bot_page = 'torqBotDeveloping'
  end

  def check_code(code)
     user = Customer.find_by(activation_code:code)
    if user
      user.update_attribute(:fb_id, sender['id'])
      Bot.deliver({
        
        recipient: sender,
        message: {
          text: 'Thank you. Your code accepted and now you can use out FB bot'
        }
      },
      access_token: ENV['ACCESS_TOKEN']
      )
    else
      Bot.deliver(
        {
          recipient: sender,
          message: {
            text: 'Sorry we didn\'t find user with provided activation code'
          }
        },
        access_token: ENV['ACCESS_TOKEN']
      )
    end  
    
  end

  def details
    card = Card.find(payload['card_id'])
    user = Customer.find(payload['user_id'])   
    Bot.deliver({
      recipient: sender,
      message: {
        attachment: {
          type: 'template',
          payload: {
            template_type: 'generic',
            elements: [
              {
                "title":"Owner: #{user.first_name.capitalize} #{user.last_name.capitalize}",
                "image_url": "#{@url}/card_icon.png",
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
      },
        access_token: ENV['ACCESS_TOKEN']
    )
  end

  def end_chat
      Bot.deliver({
        recipient: sender,
        message: {
          text: 'Bye! see you another time'
        }
       },
        access_token: ENV['ACCESS_TOKEN'] 
      )
  end

  def request_activation_code(user_id)
    text = "Hello, you need to activate your account with "+
           "your activation code received from seller.\n\n"+
           "Please enter: \"Code: {Your activation code}\n\n"+
           "\tor\t"
    buttons = [{
        type: 'postback',
        title: "Sign up",
        payload: {
          id: 'sign_up',
          user_id: user_id
        }.to_json
      }]


    Bot.deliver({
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
      },
        access_token: ENV['ACCESS_TOKEN']
    )
  end

  def sign_up
    sender_profile = get_sender_profile(sender)
    user = Customer.create(id:payload['user_id'],
                           fb_id:payload['user_id'],
                           first_name:sender_profile['first_name'],
                           last_name:sender_profile['last_name'])
     Bot.deliver(
        {
          recipient: sender,
          message: {
            text: 'Please enter phone like this:"Phone: {Your phone in international format}'
          }
        },
        access_token: ENV['ACCESS_TOKEN'] 
      )
  end

  def save_phone(phone,user)
    user_exists = Customer.exists?(phone)
    activation_code = 1000+rand(9000)
    if user_exists && user
      existed_user = Customer.find(phone)
      existed_user.update_attributes(
                                     first_name: user.first_name, 
                                     last_name: user.last_name,
                                     activation_code: activation_code
                                    )
      user.destroy
    elsif user
      user.update_attributes(activation_code:activation_code, id:phone)
    end 

    send = Twillo.send("+#{phone}","For activation please follow this link:\n"+
                                "http://m.me/#{@bot_page}?ref=#{activation_code}")

    text = if send
      'Thank you, your code will come shortly'
    else
      'Sorry something goes wrong'
    end  

    Bot.deliver(
        {
          recipient: sender,
          message: {
            text: text
          }
        },
        access_token: ENV['ACCESS_TOKEN']  
      )
  end

  def phone_verification
    text = "Sorry we didn\'t received your phone.\n"+
           "Please be sure that you enter phone in correct format like this:\n"+
           "'Phone: {Your phone in international format}'"
    Bot.deliver(
      {
        recipient: sender,
        message: {
          text: text
        }
      },
      access_token: ENV['ACCESS_TOKEN']
      )
  end

  def show_cards(user_id)
    user = Customer.find(user_id)
    buttons = user.cards.where.not(status:'expired').order(:id).map do |card|
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
        {
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
        },
        access_token: ENV['ACCESS_TOKEN']
      )
    else
      text = 'Sorry you don\'t have any cards assigned for your account'
      Bot.deliver(
        {
          recipient: sender,
          message: {
            text: text
          }
        },
        access_token: ENV['ACCESS_TOKEN'] 
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

Bot.on :referral do |referral|
  bot = CardBot.new(referral.sender, referral.ref)
  bot.check_code(referral.ref.to_i)
end

Bot.on :message do |message|
  user = Customer.find_by(fb_id:message.sender['id'])
  bot = CardBot.new(message.sender, message.text)
  case message.text
  when /\bphone\b:?\s*\+?\s*(\d+)/i
    phone = $1
  end  
  
  if phone
    bot.save_phone(phone,user)
  elsif user && user.activation_code
    puts "Sender ID: #{message.sender['id']}"
    sender = get_sender_profile(message.sender)
    puts "*************************"
    puts sender.inspect
    puts "*************************"
    bot.show_cards(user.id)
  elsif user 
    bot.phone_verification
  else  
    bot.request_activation_code(message.sender['id'])
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


