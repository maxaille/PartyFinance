# PartyFinance
Because when we organise a party we want to split costs between us, this application will make it more easily.
You just need to enter who participated and the prices and it will be divided for each participant. 
Then the organizer can set when each participant has paid.

# Prerequisites
 * MonogoDB
 * Node.js
 * Coffee-script (npm install -g coffee-script)
 * Bower (npm install -g bower)
 * Grunt (npm install -g grunt)

# Run
    npm install
    bower install
    grunt
    # start the mongoDB server
    # systemd -> systemctl start mongodb
    # upstart -> /etc/init.d/mongod start
    coffee server.coffee
    
