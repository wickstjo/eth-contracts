const contracts = [
   'Token'
]

module.exports = (deployer) => {
   contracts.forEach(name => {
      deployer.deploy(artifacts.require('./contracts/' + name + '.sol'))
   })
}