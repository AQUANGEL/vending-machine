
class VendingMachine

  COIN_NUMS = {
      "5$" => 5,
      "2$" => 2,
      "1$" => 1,
      "0.5c" => 0.5,
      "0.1c" => 0.1,
  }

  COIN_STRINGS = {
      5 => "5$",
      2 => "2$",
      1 => "1$",
      0.5 => "0.5c",
      0.1 => "0.1c",
  }

  def initialize
    @cocktails = {
        'Gin Raspberry Mule' => {
            stock: 13,
            price: 3
        },
        'Margarita' => {
            stock: 7,
            price: 1
        },
        'Mojito' => {
            stock: 11,
            price: 4
        },
        'Old Fashioned' => {
            stock: 5,
            price: 1.5
        },
    }

    @change = {
        0.1 => 5,
        0.5 => 4,
        1 => 3,
        2 => 2,
        5 => 1,
    }
  end

  def run
    puts "Welcome to the cocktail machine, please select your desired Cocktail - \n#{@cocktails.keys.join(', ')}"
    cocktail_name = gets.chomp
    if valid_cocktail?(cocktail_name)
      puts "The price for this coktail is #{@cocktails[cocktail_name][:price]}"
      puts "please insert payment in following format - 5$,2$,1$,0.5c,0.1c (these are the possible coins for payment)"

      coins_input = gets.chomp

      coins = map_valid_coins(coins_input)

      puts buy_cocktail(cocktail_name, coins)
    else
      puts "Cocktail does not exist or out of stock"
    end

    puts "Select another option? (yes - to continue, other input will result in exiting)"

    continue = gets.chomp

    if continue == "yes"
      run
    else
      puts "Goodbye"
    end
  end

  def buy_cocktail(cocktail_name, coins)
    sum = 0

    coins.each do |coin|
      sum += coin
      @change[coin] += 1
    end

    if sum < @cocktails[cocktail_name][:price]
      remove_coins_from_change(coins)

      return 'Missing money for cocktail'
    end

    returned_change = {}
    change_sum = sum - @cocktails[cocktail_name][:price]

    # calculate returned change and remaining change
    @change.keys.reverse.each do |change_type|
      next if change_sum < change_type

      count_change_type = (change_sum / change_type).to_i

      next if @change[change_type] - count_change_type.to_i <= 0

      change_sum -= (count_change_type * change_type)

      returned_change[change_type] = count_change_type

      @change[change_type] -= count_change_type.to_i
    end

    if change_sum != 0
      # refill change if not valid
      returned_change.keys.each do |change_type|
        @change[change_type] += returned_change[change_type]
      end

      remove_coins_from_change(coins)

      return 'Could not return the right amount of change'
    end

    # reduce product's stock on success
    @cocktails[cocktail_name][:stock] -= 1

    "Enjoy your #{cocktail_name} cocktail, your change is - #{get_change_string(returned_change)}"
  end

  def valid_cocktail?(cocktail_name)
    cocktail_name.is_a? String and !@cocktails[cocktail_name].nil? and @cocktails[cocktail_name][:stock] > 0
  end

  def map_valid_coins(coins_input)
    coins = coins_input.to_s.gsub(" ", "").split(",").map do |coin|
      COIN_NUMS[coin]
    end

    coins.compact
  end

  def get_change_string(returned_change)
    res = "\n"

    returned_change.keys.each do |coin_type|
      res += "#{returned_change[coin_type]} #{COIN_STRINGS[coin_type]}\n"
    end

    res
  end

  def remove_coins_from_change(coins)
    # remove inserted coins
    coins.each do |coin|
      @change[coin] -= 1
    end
  end
end

def test_missing_money
  test_machine = VendingMachine.new

  res = test_machine.buy_cocktail("Mojito", [1])

  puts res=="Missing money for cocktail" ? "passed missing money" : "failed missing money test"
end

def test_no_change
  test_machine = VendingMachine.new

  limit, count = 10, 0

  loop do
    res = test_machine.buy_cocktail("Mojito", [5])

    break if count > limit or res == "Could not return the right amount of change"

    count+=1
  end

  puts count >= limit ? "failed test" : "passed no change test"
end

test_missing_money

test_no_change

machine = VendingMachine.new

machine.run

