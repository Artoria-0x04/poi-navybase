path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem} = ReactBootstrap

{OmniShip, TeitokuPanel} = require '../parts'

render = ->
  <div>
    <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), '..', 'assets', 'navybase.css')} />
    <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), '..', 'assets', 'flex.css')} />
    <div className="panel-container flex-row">
      <TeitokuPanel />
      <div className="panel-col #{OmniShip.name}" ref="omniship" style={flex:1, marginRight: 8} >
        {React.createElement OmniShip.reactClass}
      </div>
    </div>
  </div>

module.exports = render
