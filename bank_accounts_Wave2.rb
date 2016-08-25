require 'csv'

module Bank
  class Account
    attr_accessor :id, :balance, :open_date, :owner
    def initialize(id, balance, open_date, owner)
      @id = id #account's id
      @balance = balance.to_i
      @owner = owner
      @open_date = open_date
      #initial_balance cannot be negetive
      unless @balance >= 0
        raise ArgumentError.new("Initial balance in a new account can not be negetive.")
      #raise ArugmentError when this happen
      end
    end

    def self.load_account_info(account_file_name)
      csv_account = CSV.open(account_file_name, "r")
      accounts = []
      csv_account.each do |row|
        accounts << Account.new(row[0], row[1], row[2], nil)
      end
      return accounts
    end

    def self.all
      return load_account_info("accounts.csv")
    end

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

    def to_s
      return "#{@id}, #{@balance}, #{@open_date}, #{@owner}" #instance variables on self object
    end

    #withdraw money and return updated balance
    def withdraw(money_out)
      #check whether account balance is negetive before withdraw
      @balance -= money_out
      if @balance < 0
        #prevent withdraw when balance is negetive
        puts "Sorry, you can not withdraw money as your account balance falls below zero."
        @balance += money_out
        return @balance
      else
        #allow withdraw when balance is positive
        return @balance
      end
    end

    #deposit money and return updated balance
    def deposit(money_in)
      @balance += money_in
      return @balance
    end
  end

  class Owner
    attr_accessor :id, :name, :address
    def initialize(id, name, address)
      @id = id #owner's id
      @name = name
      @address = address
    end

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

    def self.all
      return load_owner_info("owners.csv")
    end

    def to_s
      return "#{@id}, #{@name}, #{@address}" #instance variables on self object
    end

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

  end

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

owners = Bank::Owner.all
puts owners
accounts = Bank::Account.all
puts accounts

puts Bank::Account.find("1217")
puts Bank::Owner.find("15")

puts Bank::AccountOwnerLoader.load_account_owner("account_owners.csv")
