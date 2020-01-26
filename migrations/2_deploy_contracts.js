const contracts = [
   'UserManager',
   'DeviceManager',
   'TaskManager',
   'TokenManager'
]

module.exports = (deployer) => {
   contracts.forEach(path => {
      deployer.deploy(artifacts.require('./contracts/' + path + '.sol'))
   })
}