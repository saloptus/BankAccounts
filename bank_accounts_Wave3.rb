# Bank Account Wave 3:
# https://github.com/Ada-C6/BankAccounts

require 'csv'
module Bank
  #====================== ACCOUNT =============================
  # represent a bank account
  class Account
    attr_accessor :id, :balance, :open_date, :owner
    def initialize(id, balance, open_date, owner)
      @id = id #account id
      @balance = balance.to_i
      @owner = owner
      @open_date = open_date
      unless @balance >= 0
        raise ArgumentError.new("Sorry, initial balance in a new account can not be negetive.")
      end
    end

    def self.money_in_dollar(money_in_cents)
      return "$#{money_in_cents.to_f / 100.0}" # how to do two decimal?
    end

    # load account infomation from csv account file
    # input: csv file name
    # output: an array of class Account objects
    def self.load_account_info(account_file_name)
      csv_account = CSV.open(account_file_name, "r")
      accounts = []
      csv_account.each do |row|
        accounts << Account.new(row[0], row[1], row[2], nil)
      end
      return accounts
    end

    # cache csv account file - avoid repeatitve loads of the same file
    # output: an array of class Account objects
    def self.all
      if @accounts == nil
        @accounts = load_account_info("accounts.csv")
      end
      return @accounts
    end

    # identify account information by account id
    # input: account id (string)
    # output: an account object that corresponds to the given account id
    def self.find(id)
      found_account = nil
      all.each do |account|
        if id == account.id
          found_account = account
          break
        end
      end
      return found_account
    end

    # display account object information in format
    def to_s
      return "#{@id}, #{@balance}, #{@open_date}, #{@owner}" #instance variables on self object
    end

    # withdraw money from account
    def withdraw(money_out)
      if money_out < 0
        puts "Sorry, you can not withdraw a negetive amount of money."
        return @balance
      end

      if @balance < money_out
        puts "Sorry, you can not withdraw money as your account balance will fall below zero."
        return @balance
      end

      @balance -= money_out
      return @balance
    end

    # deposit money to account
    def deposit(money_in)
      if money_in < 0
        puts "Sorry, you can not deposit a negative amount of money."
        return @balance
      end

      @balance += money_in
      return @balance
    end

  end

  #======================SAVING ACCOUNT====================

  class SavingAccount < Account
    def initialize(id, balance, open_date, owner)
      super
      unless @balance >= 1000
        raise ArgumentError.new("Sorry, saving account can not be created when initial deposit less than $10.")
      end
      @trans_fee = 200
      @min_balance = 1000
    end

    def withdraw(money_out)
      if money_out < 0
        puts "Sorry, you can not withdraw a negative amount of money."
        return @balance
      end

      if @balance - @trans_fee - money_out < @min_balance
        puts "Sorry, you can not withdraw money as your account balance" +
          "falls below balance base: #{Account.money_in_dollar(@min_balance)}"
        return @balance
      end

      @balance -= @trans_fee

      return super
    end

    def add_interest(rate)
      interest_incremented = @balance * rate/100
      return interest_incremented
    end

  end
  #======================CHECKING ACCOUNT==================
  class CheckingAccount < Account
    def initialize(id, balance, open_date, owner)
      super
      @trans_fee = 100
      @check_usage = 0
      @overdraft_limit = -1000
    end

    def withdraw(money_out)
      if money_out < 0
        puts "Sorry, you can not withdraw a negetive amount of money."
        return @balance
      end

      if @balance < money_out + @trans_fee
        puts "Sorry, you can not withdraw money as your account balance falls below zero."
        return
      end

      @balance -= @trans_fee

      return super
    end

    def withdraw_using_check(money_out)
      # we will consider bounced check as check usage as well
      # therefore, we will count a check usage regardless whether
      # this check goes through
      @check_usage += 1

      if money_out < 0
        puts "Sorry, you can not withdraw a negetive amount of money."
        return @balance
      end

      # Assume testing period is within one month
      # Futher stimulation can be done by reset_checks
      this_transaction_fee = 0
      if @check_usage > 3
        this_transaction_fee = @trans_fee
      end

      if @balance - this_transaction_fee - money_out < @overdraft_limit
        puts "Sorry, you can not withdraw money as your account balance" +
          " falls below overdraft limit #{Account.money_in_dollar(@overdraft_limit)}."
        return
      end

      @balance -= this_transaction_fee
      @balance -= money_out

      return @balance
    end

    def reset_checks
      @check_usage = 0
    end

  end
  #=================MONEY MARKET ACCOUNT===================

  class MoneyMarketAccount < Account

    def initialize(id, balance, open_date, owner)
      super
      @max_trans = 6
      @min_balance = 1000000
      @Penalty_fee = 10000
      @trans_count = 0
      unless @balance >= @min_balance
        raise ArgumentError.new("Sorry, the initial balance should at least $10,000.")
      end
    end

    def withdraw(money_out)
      if money_out < 0
        puts "Sorry, you can not withdraw a negative amount of money."
        return @balance
      end

      if @balance - money_out < @min_balance
        @balance -= @Penalty_fee
        puts "Sorry, you can not withdraw money as your account balance" +
          " falls below balance base: #{Account.money_in_dollar(@min_balance)}" +
          " Each transction without funding the account first will cause" +
          " a Penalty fee #{Account.money_in_dollar(@Penalty_fee)}"
          return @balance
      end

      if @trans_count > @max_trans
        puts "Sorry, this transaction can not be completed because you exceeded" +
        "the maximum number of transaction #{@max_trans} this month."
        return @balance
      end
      super
      @trans_count += 1
      return @balance
    end

    def deposit(money_in)
      if money_in < 0
        puts "Sorry, you can not deposit a negative amount of money."
        return @balance
      end
      if @trans_count > @max_trans
        puts "Sorry, this transaction can not be completed because you exceeded" +
        "the maximum number of transaction #{@max_trans} this month."
        return @balance
      end
      super
      # No transcation count on deposit transction performed to reach or exceed minimum balance
      unless @balance < @min_balance && @balance + money_in >= @min_balance
        @trans_count += 1
      end
      return @balance
    end

    # inherit this part from checking account?
    def add_interest(rate)
      interest_incremented = @balance * rate/100
      return interest_incremented
    end

    def reset_trans
      @trans_count = 0
    end
  end
  #======================OWNER=============================
  # represent a bank account owner
  class Owner
    attr_accessor :id, :name, :address
    def initialize(id, name, address)
      @id = id #owner id
      @name = name
      @address = address
    end

    # load owner infomation from csv owner file
    # input: csv file name
    # output: an array of class Owner objects
    def self.load_owner_info(owner_file_name)
      csv_owner = CSV.open(owner_file_name, "r")
      owners = []
      csv_owner.each do |row|
        id = row[0]
        name = row[1] + row[2]
        address = row[3] + row[4] + row[5]
        owners << Owner.new(id, name, address)
      end
      return owners
    end

    # cache csv owner file - avoid repeatitve loads of the same file
    # output: an array of class Owner objects
    def self.all
      if @accounts == nil
        @accounts = load_owner_info("owners.csv")
      end
      return @accounts
    end

    # identify  owner information by owner id
    # input: owner id(string)
    # output: an owner object that corresponds to the given owner id
    def self.find(id)
      found_owner = nil
      all.each do |owner|
        if id == owner.id
          found_owner = owner
          break
        end
      end
      return found_owner
    end

    # display owner object information in format
    def to_s
      return "#{@id}, #{@name}, #{@address}" #instance variables on self object
    end

  end

  # load account with its corresponded owner
  # input: account id and owner id information file name(string)
  # output: an array of class Account objects with owner attributes

  #==================ACCOUNT_OWNER_LOADOR===================
  class AccountOwnerLoader
    def self.load_account_owner(account_owner_file_name)
      csv_acc_owner = CSV.open(account_owner_file_name, "r")
      accounts = []
      csv_acc_owner.each do |row|
        account_id = row[0]
        owner_id = row[1]
        account = Account.find(account_id)
        owner = Owner.find(owner_id)
        account.owner = owner
        accounts << account
      end
      return accounts
    end
  end
end

#===========TEST CASE FOR WAVE 2====================
# # print all owner information
# owners = Bank::Owner.all
# puts owners
# puts "---------------------"
# # print all account information
# accounts = Bank::Account.all
# puts accounts
# puts "---------------------"
#
# # print the account information of a given account id
# # return nil if can not find the account id
# puts Bank::Account.find("1217")
# puts Bank::Account.find("lgosdg")
# puts "---------------------"
# # print the owner information of a given owner id
# # return nil if can not find the owner id
# puts Bank::Owner.find("15")
# puts Bank::Owner.find("983")
# puts "---------------------"
# # print all account's information and its owner's information given the account id and owner id relationship
# puts Bank::AccountOwnerLoader.load_account_owner("account_owners.csv")

#===========TEST CASE FOR WAVE 3====================
puts "--------SAVING ACCOUNT TEST------------"
new_saving = Bank::SavingAccount.new(nil, 2000, nil, nil)
puts new_saving.inspect
puts Bank::Account.money_in_dollar(new_saving.withdraw(900))
puts Bank::Account.money_in_dollar(new_saving.deposit(300))
puts Bank::Account.money_in_dollar(new_saving.add_interest(0.25))
puts new_saving.inspect
puts "--------CHECKING ACCOUNT TEST---------------"
new_checking = Bank::CheckingAccount.new(nil, 4000, nil, nil)
puts new_checking.inspect
puts Bank::Account.money_in_dollar(new_checking.withdraw(800))
puts Bank::Account.money_in_dollar(new_checking.deposit(400))
4.times {puts  Bank::Account.money_in_dollar(new_checking.withdraw_using_check(2000))}
puts new_checking.inspect
puts "--------MONEY MARKET ACCOUNT TEST---------------"
new_market = Bank::MoneyMarketAccount.new(nil, 1000000, nil, nil)
puts new_market.inspect
4.times {puts Bank::Account.money_in_dollar(new_market.withdraw(400000))}
puts Bank::Account.money_in_dollar(new_market.deposit(800000))
puts Bank::Account.money_in_dollar(new_market.add_interest(3))
puts new_market.inspect
puts "-----------------------"
