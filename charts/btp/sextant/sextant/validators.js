const dns1123 = [
  'matches', ['^[a-z]([-a-z0-9]*[a-z0-9])*$'],
  'a DNS-1123 label must consist of lower case alphanumeric characters or \'-\', and must start and end with an alphanumeric character',
]

const password = ['matches', '^\\S*$', 'Cannot contain spaces']

module.exports = {
  dns1123,
  password,
}
