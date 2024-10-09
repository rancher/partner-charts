const randomString = require('randomstring')
const options = require('./options')

const form = [

  'Hyperledger Sawtooth Deployment',

  [
    {
      id: 'sawtooth.networkName',
      title: 'Deployment Name',
      helperText: 'The name of the deployment',
      component: 'text',
      editable: {
        new: true,
      },
      validate: {
        type: 'string',
        methods: [
          ['required', 'Required'],
          ['matches', ['^[a-z]([-a-z0-9]*[a-z0-9])*$'], "a DNS-1123 label must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character"],
        ],
      },
    },
    {
      id: 'sawtooth.namespace',
      title: 'Kubernetes Namespace',
      helperText: 'The Kubernetes namespace',
      component: 'text',
      editable: {
        new: true,
      },
      validate: {
        type: 'string',
        methods: [
          ['required', 'Required'],
          ['matches', ['^[a-z]([-a-z0-9]*[a-z0-9])*$'], "a DNS-1123 label must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character"],
        ],
      },
    },

  ],

  [
    {
      id: 'sawtooth.dynamicPeering',
      title: 'Peering Type',
      helperText: 'Peering type for the validator',
      component: 'radio',
      default: true,
      dataType: 'boolean',
      row: true,
      options: options.peering,
      validate: {
        type: 'string',
        methods: [
          ['required', 'Required'],
        ],
      },
    },
    {
      id: 'sawtooth.genesis.enabled',
      title: 'Genesis Block',
      helperText: 'Should this network create the genesis block?',
      component: 'radio',
      default: true,
      dataType: 'boolean',
      row: true,
      options: options.activated,
      validate: {
        type: 'string',
        methods: [
          ['required', 'Required'],
        ],
      },
    },
  ],
  [
    {
      id: 'sawtooth.permissioned',
      title: 'Permissioned Network',
      helperText: 'Should this network be permissioned?',
      component: 'radio',
      default: false,
      dataType: 'boolean',
      row: true,
      options: options.activated,
      validate: {
        type: 'string',
        methods: [
          ['required', 'Required'],
        ],
      },
    },
    {
      id: 'sawtooth.consensus',
      title: 'Consensus Algorithm',
      helperText: 'Which consensus algorithm should this network use?',
      component: 'select',
      alternateText: true,
      default: 400,
      dataType: 'number',
      options: options.consensus,
      validate: {
        type: 'number',
        methods: [
          ['required', 'Required'],
        ],
      },
    },
  ],

  {
    id: 'affinity.enabled',
    title: 'Affinity',
    helperText: 'If enabled - pods will only deploy to nodes that have the label: app={{ .Release.Name }}-validator',
    component: 'radio',
    default: false,
    dataType: 'boolean',
    row: true,
    options: options.activated,
    validate: {
      type: 'string',
      methods: [
        ['required', 'Required'],
      ],
    },
  },

  // hostname, IP, port
  {
    id: 'sawtooth.externalSeeds',
    title: 'External Seeds',
    helperText: 'The list of external addresses to connect to',
    list: {
      mainField: 'hostname',
      schema: [{
        id: 'hostname',
        title: 'Hostname',
        helperText: 'Type the hostname of a new external seed.',
        component: 'text',
        validate: {
          type: 'string',
          methods: [
            ['required', 'Required'],
            ['matches', ['^[a-z]([.]*[-a-z0-9]*[a-z0-9])*$'], 'Must use a DNS-1123 safe label.'],
          ],
        },
      },
      {
        id: 'ip',
        title: 'IP Address',
        helperText: 'Type the IP address of a new external seed.',
        component: 'text',
        validate: {
          type: 'string',
          methods: [
            ['required', 'Required'],
            ['matches', ['^[0-9]+[.0-9]*[0-9]$'], 'Must be an IPv4 compatible address.'],
          ],
        },
      }, {
        id: 'port',
        title: 'Port',
        helperText: 'Type the port of a new external seed.',
        component: 'text',
        validate: {
          type: 'string',
          methods: [
            ['required', 'Required'],
            ['matches', ['^[0-9]+$'], 'Must be a number.'],
          ],
        },
      },
      ],
      table: [{
        title: 'Hostname',
        name: 'hostname',
      }, {
        title: 'IP Address',
        name: 'ip',
      }, {
        title: 'Port',
        name: 'port',
      }],
    },
  },

  'Custom Containers',

  {
    id: 'sawtooth.customTPs',
    title: 'Custom Containers',
    skip: true,
    helperText: 'Custom containers can connect to the validator on tcp://localhost:4004',
    list: {
      mainField: 'name',
      schema: [{
        id: 'name',
        title: 'Name',
        helperText: 'The name of your custom container',
        component: 'text',
        validate: {
          type: 'string',
          methods: [
            ['required', 'Required'],
          ],
        },
      }, {
        id: 'image',
        title: 'Image',
        helperText: 'The docker image for your container',
        component: 'text',
        validate: {
          type: 'string',
          methods: [
            ['required', 'Required'],
          ],
        },
      }, {
        id: 'command',
        title: 'Command',
        helperText: 'The command for your container',
        component: 'text',
        validate: {
          type: 'string',
          methods: [

          ],
        },
      }, {
        id: 'args',
        title: 'Arguments',
        helperText: 'The arguments for your container',
        component: 'text',
        validate: {
          type: 'string',
          methods: [

          ],
        },
      }],
      table: [{
        title: 'Name',
        name: 'name',
      }, {
        title: 'Image',
        name: 'image',
      }, {
        title: 'Command',
        name: 'command',
      }, {
        title: 'Arguments',
        name: 'args',
      }],
    },
  },

  'Image Pull Secrets',

  {
    id: 'imagePullSecrets.enabled',
    title: 'Do you need to enable image pull secrets?',
    helperText: 'Provide secrets to be injected into the namespace and used to pull images from your secure registry',
    component: 'radio',
    default: false,
    dataType: 'boolean',
    row: true,
    options: options.yesNo,
    validate: {
      type: 'string',
      methods: [
        ['required', 'Required'],
      ],
    },
  }, {
    id: 'imagePullSecrets.value',
    title: 'Image Pull Secrets',
    helperText: null,
    default: null,
    linked: {
      linkedId: 'imagePullSecrets.enabled',
      visibilityParameter: 'true', // for what value of linkedId, will this component be visible
    },
    list: {
      mainField: 'name',
      schema: [{
        id: 'name',
        title: 'Name',
        helperText: 'The name of the secret',
        component: 'text',
        validate: {
          type: 'string',
          methods: [
            ['required', 'Required'],
            ['matches', ['^[a-z]([-a-z0-9]*[a-z0-9])*$'], "a DNS-1123 label must consist of lower case alphanumeric characters or '-', and must start and end with an alphanumeric character"],
          ],
        },
      }],
      table: [{
        title: 'Name',
        name: 'name',
      }],
    },
  },

  'Advanced Options',

  [
    {
      id: 'sawtooth.genesis.seed',
      title: 'Genesis Seed',
      hidden: true,
      default: randomString.generate(24),
      warning: true,
      helperText: 'WARNING: Changing the Genesis Seed will cause any exisiting data on the deployment to be deleted.',
      component: 'text',
      validate: {
        type: 'string',
        methods: [
          ['required', 'Required'],
        ],
      },
    },
    '', // emptry string acts as space in UI
  ],

]

module.exports = form
