const activated = [{
  value: true,
  title: 'Enabled',
}, {
  value: false,
  title: 'Disabled',
}]

const yesNo = [{
  value: true,
  title: 'Yes',
}, {
  value: false,
  title: 'No',
}]

const consensus = [{
  value: 100,
  title: 'DevMode',
  blurb: 'DevMode is useful for development purposes only. This mechanism useful only on single node networks which provide no real consensus guarantees.',
}, {
  value: 400,
  title: 'PBFT',
  blurb: 'PBFT is a byzantine fault tolerant consensus mechanism offering good scale, and performance. It is tolerant of up to f=(n-1)/3 byzantine or other faults on the network. PBFT is a non-forking algorithm.',
}, {
  value: 200,
  title: 'PoET-CFT',
  blurb: 'PoET-CFT is a time based consensus mechanism based on a fair lottery system. It has low resource utilization, is crash fault tolerant and can support very large scale networks. PoET-CFT is a forking consensus algorithm.',
}, {
  value: 300,
  title: 'Raft',
  blurb: 'Raft is a consensus mechanism based on an elected leader. It offers good performance, but is not tolerant of Byzantine failures. It works best with low latency networks, and is tolerant of f=(n-1)/2 non-byzantine failures. Raft is a non-forking algorithm.',
}]

const peering = [{
  value: true,
  title: 'Dynamic',
}, {
  value: false,
  title: 'Static',
}]

module.exports = {
  activated,
  consensus,
  peering,
  yesNo,
}
