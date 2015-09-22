path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{TabbedArea, TabPane, Grid, Col, Row, Accordion, Panel, Nav, NavItem} = ReactBootstrap
{MissionPanel, NdockPanel, KdockPanel, TaskPanel, MiniShip, TeitokuPanel, CombinedPanel} = require './parts'

i18n = require './node_modules/i18n'
{__} = i18n

i18n.configure
  locales: ['en_US', 'ja_JP', 'zh_CN']
  defaultLocale: 'zh_CN'
  directory: path.join(__dirname, 'i18n')
  updateFiles: false
  indent: '\t'
  extension: '.json'
i18n.setLocale(window.language)

module.exports =
  name: 'compactview'
  priority: 100000
  displayName: [<FontAwesome key={0} name='clock-o' />, ' 迷你母港']
  description: '超压缩母港面板，提供各种基本信息'
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
      if layout == 'horizontal'
        <div>
          <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), 'assets', 'compactview.css')} />
          <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), 'assets', 'flex.css')} />
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
            <div className="panel-col #{MiniShip.name}" ref="miniship" style={flex:1} >
              {React.createElement MiniShip.reactClass}
            </div>
          </div>
        </div>
      else
        <div>
          <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), 'assets', 'compactview.css')} />
          <link rel="stylesheet" href={path.join(path.relative(ROOT, __dirname), 'assets', 'flex.css')} />
          <div className="panel-container flex-row">
            <TeitokuPanel />
            <div className="panel-col #{MiniShip.name}" ref="miniship" style={flex:1} >
              {React.createElement MiniShip.reactClass}
            </div>
            <div className="panel-col #{MiniShip.name}" ref="miniship" style={flex:1, marginRight: 8} >
              {React.createElement MiniShip.reactClass}
            </div>
          </div>
        </div>
