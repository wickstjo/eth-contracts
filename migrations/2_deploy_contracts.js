const contracts = [
   'UserManager',
   'DeviceManager',
   'TaskManager'
]

module.exports = (deployer) => {
   contracts.forEach(path => {
      deployer.deploy(artifacts.require('./contracts/' + path + '.sol'))
   })
}