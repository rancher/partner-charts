const activated = [{
  value: true,
  title: 'Enabled',
}, {
  value: false,
  title: 'Disabled',
}]

const passwordOrSecret = [
  {
    value: true,
    title: 'Password',
  },
  {
    value: false,
    title: 'Existing Secret',
  },

]

const yesNo = [{
  value: true,
  title: 'Yes',
}, {
  value: false,
  title: 'No',
}]

module.exports = {
  activated,
  yesNo,
  passwordOrSecret,
}
