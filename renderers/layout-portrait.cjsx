path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem} = ReactBootstrap

{OmniShip, TeitokuPanel, MissionPanel, TaskPanel} = require '../parts'

render = ->
  <div>
    <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), '..', 'assets', 'navybase.css')} />
    <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), '..', 'assets', 'flex.css')} />
    <div className="panel-container flex-column">
      <TeitokuPanel />
      <div className="flex-column" style={flex:1}>
        <div className="panel-col mission-panel" ref="missionPanel" >
          <MissionPanel />
        </div>
        <div className="panel-col task-panel" ref="taskPanel" >
          <TaskPanel />
        </div>
      </div>
      <div className="panel-col #{OmniShip.name}" ref="omniship" style={flex:1} >
        {React.createElement OmniShip.reactClass}
      </div>
    </div>
  </div>

module.exports = render
