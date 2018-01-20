require 'colorize'
require 'sinatra'

BALANCES = {
  'joe' => 1_000_000,
}

def print_balance
  puts BALANCES.to_s.yellow
end

# @param user
get "/balance" do
  user = params['user'].downcase
  print_balance
  "#{user} has #{BALANCES[user]}"
end

# @param name
post "/users" do
  name = params['name'].downcase
  BALANCES[name] ||= 0
  print_balance
  "OK"
end

# @param from
# @param to
# @param amount
post "/transfers" do
  from, to = params.values_at('from', 'to').map(&:downcase)
  amount = params['amount'].to_i
  raise unless BALANCES[from] >= amount
  BALANCES[from] -= amount
  BALANCES[to] += amount
  print_balance
  'OK'
end
