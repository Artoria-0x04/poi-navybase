path = require 'path-extra'
{layout, ROOT, $, $$, React, ReactBootstrap} = window
{layout, tabbed} = window
{MissionPanel, NdockPanel, KdockPanel, TaskPanel, OmniShip, TeitokuPanel, CombinedPanel} = require './parts'
{LayoutLandescape, LayoutPortrait} = require './renderers'

i18n = require './node_modules/i18n'
{__} = i18n

i18n.configure
  locales: ['en_US', 'ja_JP', 'zh_CN', 'zh_TW']
  defaultLocale: 'zh_CN'
  directory: path.join(__dirname, 'i18n')
  updateFiles: false
  indent: '\t'
  extension: '.json'
i18n.setLocale(window.language)

# TODO remove other translations in i18n

module.exports =
  name: 'NavyBase'
  priority: 100000
  displayName: <span><FontAwesome key={0} name='home' />{__ ' Overview'}</span>
  description: '母港'
  reactClass: React.createClass
    getInitialState: ->
      null
    handleChangeLayout: (e) ->
      {layout} = e.detail
      # all horizontal, vertical double
      if layout == 'horizontal' or (tabbed == 'double' and layout == 'vertical')
        @render = LayoutPortrait
      else
        @render = LayoutLandescape
    componentDidMount: ->
      window.addEventListener 'layout.change', @handleChangeLayout
    componentWillUnmount: ->
      window.removeEventListener 'layout.change', @handleChangeLayout
    componentWillUnmount: ->
      if layout == 'horizontal' or (tabbed == 'double' and layout == 'vertical')
        @render = LayoutPortrait
      else
        @render = LayoutLandescape
    render: ->
      <div>
      </div>
