require 'csv'

module Bank
  # represent a bank account
  class Account
    attr_accessor :id, :balance, :open_date, :owner
    def initialize(id, balance, open_date, owner)
      @id = id #account id
      @balance = balance.to_i
      @owner = owner
      @open_date = open_date
      unless @balance >= 0
        raise ArgumentError.new("Initial balance in a new account can not be negetive.")
      end
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
      @balance -= money_out
      if @balance < 0
        puts "Sorry, you can not withdraw money as your account balance falls below zero."
        @balance += money_out
        return @balance
      else
        return @balance
      end
    end

    # deposit money to account
    def deposit(money_in)
      @balance += money_in
      if money_in < 0
        @balance -= money_in
        puts "Sorry, you can not deposit a negetive amount of money."
      end
      return @balance
    end

  end

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

# print all owner information
owners = Bank::Owner.all
puts owners
# print all account information
accounts = Bank::Account.all
puts accounts

# print the account information of a given account id
# return nil if can not find the account id
puts Bank::Account.find("1217")
puts Bank::Account.find("lgosdg")

# print the owner information of a given owner id
# return nil if can not find the owner id
puts Bank::Owner.find("15")
puts Bank::Owner.find("983")

# print all account's information and its owner's information given the account id and owner id relationship
puts Bank::AccountOwnerLoader.load_account_owner("account_owners.csv")
