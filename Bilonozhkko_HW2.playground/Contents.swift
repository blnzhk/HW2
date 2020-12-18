import Foundation

enum StatusUser {
    case admin
    case regular
}

enum StateAccount {
    case logIn
    case logOut
    case Banned
}

enum SystemError: Error {
    case youCanNotDoThis
}

enum RegisterError: Error {
    case usernameCount
    case passwordCount
    case age
    case name
    case userExists
}

enum LogINError: Error {
    case youAreBanned
    case inCorrectUsernameOrPassword
}

var baseUserAccount = [String: User] ()
var baseOfBat = [String: [String]] ()

class BetSystem {
    
   private func registerNewUser (username: String, password: String, name: String, age: Int, status: StatusUser ) throws -> User {
        if username.count < 1 || username.count > 20 {
            throw RegisterError.usernameCount
        }
        if name.count < 1 || name.count > 20 {
            throw RegisterError.name
        }
        if age < 18 {
            throw RegisterError.age
        }
        if password.count < 8 || password.count > 20 {
            throw RegisterError.passwordCount
        }
        if (baseUserAccount[username] != nil) {
            throw RegisterError.userExists
        }
        baseUserAccount[username] = User(name: name, age: age, userName: username, password: password, status: status, state: .logOut)
        return User(name: name, age: age, userName: username, password: password, status: status, state: .logOut )
    }
    
    func registerNewUserThrows(username: String, password: String, name: String, age: Int, status: StatusUser) throws -> User {
        var user = User()
        do {
             try user = registerNewUser(username: username, password: password, name: name, age: age, status: status)
        } catch RegisterError.usernameCount {
            print("Username must contain at least one character and be no more than 10 characters")
        } catch RegisterError.passwordCount {
            print("Password length must be at least 8 characters")
        } catch RegisterError.age {
            print("You must be over 18 years old")
        } catch RegisterError.name {
            print("This user alredy exists")
        } catch RegisterError.userExists {
            print("This user alredy exists")
        }
       return user
    }
    
    private func logIn(_ user: inout User, password: String) throws  {
        if user.password == password {
            if user.state == .Banned {
                throw LogINError.youAreBanned
            } else {
                user.state = .logIn
            }
        } else {
            throw LogINError.inCorrectUsernameOrPassword
        }

    }
    
    func logIn1(_ user: inout User, password: String) throws  {
        do {
            try logIn(&user, password: password)
        } catch LogINError.youAreBanned {
            print("Sorry you can not log in our system. You ara banned!")
        } catch LogINError.inCorrectUsernameOrPassword {
            print("Check the correctness of the login and password")
        }
    }
    
    func logOut(_ user: inout User) -> Bool {
        if user.state == .logIn {
            user.state = .logOut
        }
        return true
    }
    
}

struct User: AdminUser, RegularUser {
    var name: String?
    var age: Int?
    var userName: String?
    var status: StatusUser?
    var state: StateAccount?
    var password: String?
    
    init (name: String, age: Int, userName: String, password: String, status: StatusUser, state: StateAccount) {
        self.name = name
        self.age = age
        self.password = password
        self.userName = userName
        self.status = status
        self.state = state
    }
    
    init() {}
    
}

protocol RegularUser {}

extension RegularUser {
    
    
    private func newBet1(_ user: inout User, money: Int) throws -> Bool {
        if user.status == .regular && user.state == .logIn {
            let bat = "You place a bet with \(money)"
            var list = baseOfBat[user.userName!] ?? []
            list.append(bat)
            baseOfBat[user.userName!] = list
        } else {
            throw SystemError.youCanNotDoThis
        }
        return true
    }
    
    func newBet(_ user: inout User, money: Int) throws {
        do {
            try newBet1(&user, money: money)
        } catch SystemError.youCanNotDoThis {
            print("Only regular user can performm this action!")
        }
        
    }
        
   private func printAListOfBet1(_ user: inout User) throws -> Bool {
        if user.status == .regular && user.state == .logIn {
            guard let arrayCount = baseOfBat[user.userName!]?.count else { return false }
            for var i in 0..<arrayCount {
                    print(baseOfBat[user.userName!]![i])
                    i += 1
                }
                return true
        } else {
            throw SystemError.youCanNotDoThis
        }
    
        }
    
    func printAListOfBet(_ user: inout User) throws {
        do {
            try printAListOfBet1(&user)
        } catch SystemError.youCanNotDoThis {
            print("Only regular user can performm this action!")
        }
        
    }
        
}

protocol AdminUser {}

extension AdminUser {

    private func  browsAll1(_ user: inout User) throws -> Bool {
        if user.status == .admin && user.state == .logIn  {
                for (_ , value) in baseUserAccount {
                    print("User: \(String(describing: value.userName)), name: \(String(describing: value.name)), age: \(String(describing: value.age))")
                }
                return true
        } else {
            throw SystemError.youCanNotDoThis
        }
    }
    
    func browsAll(_ user: inout User) throws {
        do {
            try browsAll1(&user)
        } catch SystemError.youCanNotDoThis {
            print("Only admin can performm this action!")
        }
    }
    
    private func banUser1(admin: inout User, user: inout User) throws -> Bool {
        if admin.status == .admin && admin.state == .logIn {
            user.state = .Banned
            return true
        } else {
            throw SystemError.youCanNotDoThis
        }
    }
    
    func banUser(admin: inout User, user: inout User) throws {
        do {
            try banUser1(admin: &admin, user: &user)
        } catch SystemError.youCanNotDoThis {
            print("Only admin can performm this action!")
        }
    }
}

var system = BetSystem()
var user1 = try system.registerNewUserThrows(username: "username", password: "11111111", name: "Anna", age: 20, status: .regular)
var user2 = try system.registerNewUserThrows(username: "username1", password: "22222222", name: "Kate", age: 23, status: .admin)
try system.logIn1(&user1, password: user1.password!)
try user1.newBet(&user1, money: 50)
try user1.newBet(&user1, money: 100)
try user1.printAListOfBet(&user1)
system.logOut(&user1)
try system.logIn1(&user2, password: user2.password!)
try user2.browsAll(&user2)
try user2.banUser(admin: &user2, user: &user1)
system.logOut(&user2)
try system.logIn1(&user1, password: user1.password!)
var user3 = try system.registerNewUserThrows(username: "username2", password: "33333333", name: "Li", age: 16, status: .regular)
var user4 = try system.registerNewUserThrows(username: "username3", password: "44444444", name: "ke", age: 25, status: .regular)
try system.logIn1(&user4, password: user4.password!)


