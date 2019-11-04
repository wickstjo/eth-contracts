# COMPILE CONTRACTS
truffle migrate

# MOVE THE CONTRACT REFERENCES
mv -f ./build/contracts temp

# REMOVE THE BUILD DIR
rm -rf ./build

# RENAME THE TEMP DIR
mv -f ./temp build

# COPY REFERENCES TO THE OTHER PROJECTS
#node ./scripts/transfer.js

# truffle console
# Main.deployed().then(function(instance) { app = instance })