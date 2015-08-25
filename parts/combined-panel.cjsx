path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{Nav, NavItem, Panel} = ReactBootstrap
NdockPanel = require './ndock-panel'
KdockPanel = require './kdock-panel'

CombinedPanel = React.createClass
  getInitialState: ->
    key: 1
  handleSelect: (key) ->
    @setState {key}
    @forceUpdate()
  render: ->
    <Panel className="combined-panel flex-column" style={alignItems:"center", justifyContent:"space-between"}>
      <Nav bsStyle='pills' stacked activeKey={@state.key} onSelect={@handleSelect}>
        <NavItem key={0} eventKey={0} id="nav-item-kdock">建造</NavItem>
        <NavItem key={1} eventKey={1} id="nav-item-ndock">入渠</NavItem>
      </Nav>
      <div className={"panel-col kdock-panel " + if @state.key == 0 then 'show' else 'hidden'} eventKey={0} key={0} style={flex: 1}>
        <KdockPanel />
      </div>
      <div className={"panel-col ndock-panel " + if @state.key == 1 then 'show' else 'hidden'} eventKey={1} key={1} style={flex: 1}>
        <NdockPanel />
      </div>
    </Panel>

module.exports = CombinedPanel
