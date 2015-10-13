path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{Nav, NavItem, Button, ButtonGroup, Panel} = ReactBootstrap
{__, __n} = require 'i18n'

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
      <ButtonGroup>
        <Button key={0} bsSize="small" ventKey={0} onClick={@handleSelect.bind(this, 0)} className={if @state.key == 0 then 'active' else ''} id="nav-item-kdock">建造</Button>
        <Button key={1} bsSize="small" eventKey={1} onClick={@handleSelect.bind(this, 1)} className={if @state.key == 1 then 'active' else ''}>入渠</Button>
      </ButtonGroup>
      <div className={"panel-col kdock-panel " + if @state.key == 0 then 'show' else 'hidden'} eventKey={0} key={0} style={flex: 1}>
        <KdockPanel />
      </div>
      <div className={"panel-col ndock-panel " + if @state.key == 1 then 'show' else 'hidden'} eventKey={1} key={1} style={flex: 1}>
        <NdockPanel />
      </div>
    </Panel>

module.exports = CombinedPanel
