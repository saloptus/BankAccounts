module Bank
  class Account
    attr_accessor :id, :balance, :owner
    def initialize(id, balance, owner)
      @id = id
      @balance = balance.to_f
      @owner = owner
      #initial_balance cannot be negetive
      unless balance >= 0
        raise ArgumentError.new("Initial balance in a new account can not be negetive.")
      #raise ArugmentError when this happen
      end
    end

    #withdraw money and return updated balance
    def withdraw(money_out)
      #check whether account balance is negetive before withdraw
      @balance -= money_out
      if @balance < 0
        #prevent withdraw when balance is negetive
        puts "Sorry, you can not withdraw money as your account balance falls below zero."
        @balance += money_out
      end
      return @balance
    end

    #deposit money and return updated balance
    def deposit(money_in)
      @balance += money_in
      if money_in < 0
        #prevent withdraw when balance is negetive
        @balance -= money_in
        puts "Sorry, you can not deposit a negetive amount of money."
      end
      return @balance
    end

  end

  class Owner
    attr_accessor :name, :address
    def initialize(name, address)
      @name = name
      @address = address
    end
  end

end

#my_account = Bank::Account.new("001", -10)
new_owner = Bank::Owner.new("David", "8998 101th Ave, Honolulu, Hawaii")
new_account = Bank::Account.new("001", 0, new_owner)

puts new_account.deposit(-20)
puts new_account.deposit(100)
puts new_account.withdraw(700)

puts new_account.balance
