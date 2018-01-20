require 'colorize'
require 'sinatra'

BALANCES = {
  'joe' = 1_000_000,
}

# @param user
get "/balance" do
  user = params['user']
  puts BALANCES.to_s.yello
  "#{user} has #{BALANCES[user]}"
end

# @param name
get "/users" do
  name = params['name']
  BALANCES[name] ||= 0
  puts BALANCES.to_s.yello
  "OK"
end

# @param from
# @param to
# @param amount
get "/transfers" do
  from, to = params.values_at('from', 'to').map(&downcase)
  amount = params['amount'].to_i
  raise unless BALANCES['from'] >= amount
  BALANCES['from'] -= amount
  BALANCES['to'] += amount
  puts BALANCES.to_s.yello
  'OK'
end
