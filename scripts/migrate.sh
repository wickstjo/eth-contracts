# REMOVE THE OLD BUILD DIR
rm -rf ./build

# MIGRATE CONTRACTS TO THE BLOCKCHAIN
truffle migrate

# COPY REFERENCES TO THE OTHER PROJECTS
node ./scripts/transfer.js