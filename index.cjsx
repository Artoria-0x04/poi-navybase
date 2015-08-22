path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem} = ReactBootstrap
{MissionPanel, NdockPanel, KdockPanel, TaskPanel, MiniShip, TeitokuPanel, CombinedPanel} = require './parts'

module.exports =
  name: 'TimeGauge'
  priority: 100000
  displayName: [<FontAwesome key={0} name='clock-o' />, ' 计时面板']
  description: '计时面板，提供舰队各种信息倒计时'
  reactClass: React.createClass
    getInitialState: ->
      xs: if layout == 'horizonal' then 6 else 6
    handleChangeLayout: (e) ->
      {layout} = e.detail
      @setState
        xs: if layout == 'horizonal' then 6 else 6
    componentDidMount: ->
      window.addEventListener 'layout.change', @handleChangeLayout
    componentWillUnmount: ->
      window.removeEventListener 'layout.change', @handleChangeLayout
    shouldComponentUpdate: (nextProps, nextState)->
      false
    render: ->
      <div>
        <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), 'assets', 'timegauge.css')} />
        <div className="panel-container">
          <TeitokuPanel />
          <div style={display:"flex", flexFlow:"column", flex:1}>
            <div className="panel-col mission-panel" ref="missionPanel" >
              <MissionPanel />
            </div>
            <div className="panel-col task-panel" ref="taskPanel" >
              <TaskPanel />
            </div>
          </div>
          <div className="panel-col miniship" id={MiniShip.name} ref="miniship" style={flex:1} >
            {React.createElement MiniShip.reactClass}
          </div>
        </div>
      </div>
