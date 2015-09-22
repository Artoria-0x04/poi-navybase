{relative, join} = require 'path-extra'
{_, $, $$, React, ReactBootstrap, ROOT, toggleModal} = window
{$ships, $shipTypes, _ships} = window
{Button, ButtonGroup} = ReactBootstrap
{ProgressBar, OverlayTrigger, Tooltip, Alert, Overlay, Label, Panel, Popover} = ReactBootstrap
{__, __n} = require 'i18n'

# {getDeckState} = require './deck-info'
PaneBody = require './panebody'

inBattle = [false, false, false, false]
goback = {}
combined = false
escapeId = -1
towId = -1

getStyle = (state) ->
  if state in [0..5]
    # 0: Cond >= 40, Supplied, Repaired, In port
    # 1: 20 <= Cond < 40, or not supplied, or medium damage
    # 2: Cond < 20, or heavy damage
    # 3: Repairing
    # 4: In mission
    # 5: In map
    return ['success', 'warning', 'danger', 'info', 'default', 'primary'][state]
  else
    return 'default'

getDeckState = (deck) ->
  state = 0
  {$ships, _ships} = window
  # In mission
  if inBattle[deck.api_id - 1]
    state = Math.max(state, 5)
  if deck.api_mission[0] > 0
    state = Math.max(state, 4)
  for shipId in deck.api_ship
    continue if shipId == -1
    ship = _ships[shipId]
    shipInfo = $ships[ship.api_ship_id]
    # Cond < 20 or medium damage
    if ship.api_cond < 20 || ship.api_nowhp / ship.api_maxhp < 0.25
      state = Math.max(state, 2)
    # Cond < 40 or heavy damage
    else if ship.api_cond < 40 || ship.api_nowhp / ship.api_maxhp < 0.5
      state = Math.max(state, 1)
    # Not supplied
    if ship.api_fuel / shipInfo.api_fuel_max < 0.99 || ship.api_bull / shipInfo.api_bull_max < 0.99
      state = Math.max(state, 1)
    # Repairing
    if shipId in window._ndocks
      state = Math.max(state, 3)
  state

DeckInfo = React.createClass
  messages: ['没有舰队信息']
  maxCountdown: 0
  getInitialState: ->
    inMission: false
  getState: ->
    if @state.inMission
      return '远征'
    else
      return '回复'
  render: ->
    <div style={display: "flex", justifyContent: "space-around", padding:5}>
      <span style={flex: "none"}>总 Lv.{@messages.totalLv}</span>
      <span style={flex: "none"}>均 Lv.{@messages.avgLv}</span>
      <span style={flex: "none"}>制空:&nbsp;{@messages.tyku}</span>
      <span style={flex: "none"}>{@getState()}:&nbsp;<span id={"deck-condition-countdown-#{@props.deckIndex}"}>{resolveTime @maxCountdown}</span></span>
    </div>

module.exports =
  name: 'miniship'
  priority: 100000.1
  displayName: <span><FontAwesome key={0} name='bars' /> Mini舰队</span>
  description: '舰队展示页面，展示舰队详情信息'
  reactClass: React.createClass
    getInitialState: ->
      names: ['I', 'II', 'III', 'IV']
      states: [-1, -1, -1, -1]
      decks: []
      activeDeck: 0
      dataVersion: 0
    showDataVersion: 0
    condStartTime: {}
    shouldComponentUpdate: (nextProps, nextState)->
      # if ship-pane is visibile and dataVersion is changed, this pane should update!
      if nextProps.selectedKey is @props.index and nextState.dataVersion isnt @showDataVersion
        @showDataVersion = nextState.dataVersion
        return true
      if @state.decks.length is 0 and nextState.decks.length isnt 0
        return true
      false
    handleClick: (idx) ->
      if idx isnt @state.activeDeck
        @setState
          activeDeck: idx
          dataVersion: @state.dataVersion + 1
    handleResponse: (e) ->
      {method, path, body, postBody} = e.detail
      {names} = @state
      flag = true
      switch path
        when '/kcsapi/api_port/port'
          # names = body.api_deck_port.map (e) -> e.api_name
          inBattle = [false, false, false, false]
          for shipId of _ships
            t = new Date().getTime()
            if @condStartTime[shipId]?
              if _ships[shipId].api_cond >= 49
                @condStartTime[shipId] = 0
                continue
              if @condStartTime[shipId] > 0
                step = (t - @condStartTime[shipId]) / (3 * 60 * 1000)
                if step >= 1
                  # forward time
                  @condStartTime[shipId] += 3 * 60 * 1000 * Math.floor(step)
              else
                @condStartTime[shipId] = t
            else
              @condStartTime[shipId] = t
            # Math.ceil((49 - _ships[shipId].api_cond) / 3) * 3 * 60 * 1000 + t.getTime()
        when '/kcsapi/api_req_hensei/change', '/kcsapi/api_req_hokyu/charge', '/kcsapi/api_get_member/deck', '/kcsapi/api_get_member/ship_deck', '/kcsapi/api_get_member/ship2', '/kcsapi/api_get_member/ship3',  '/kcsapi/api_req_kaisou/powerup', '/kcsapi/api_req_nyukyo/start', '/kcsapi/api_req_nyukyo/speedchange'
          true
        when '/kcsapi/api_req_kousyou/destroyship'
          shipId = parseInt postBody.api_ship_id
          delete @condStartTime[shipId]
          true
        when '/kcsapi/api_req_map/start'
          deckId = parseInt(postBody.api_deck_id) - 1
          inBattle[deckId] = true
          {decks, states} = @state
          {_ships} = window
          deck = decks[deckId]
        else
          flag = false
      return unless flag
      decks = window._decks
      states = decks.map (deck) ->
        getDeckState deck
      @setState
        names: names
        decks: decks
        states: states
        dataVersion: @state.dataVersion + 1
    componentDidMount: ->
      window.addEventListener 'game.response', @handleResponse
    componentWillUnmount: ->
      window.removeEventListener 'game.response', @handleResponse
      @interval = clearInterval @interval if @interval?
    render: ->
      <Panel bsStyle="default" >
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'miniship.css')} />
        <link rel="stylesheet" href={join(relative(ROOT, __dirname), 'assets', 'flex.css')} />
        <ButtonGroup>
        {
          for i in [0..3]
            <Button key={i} bsSize="small"
                            bsStyle={getStyle @state.states[i]}
                            onClick={@handleClick.bind(this, i)}
                            className={if @state.activeDeck == i then 'active' else ''}>
              {@state.names[i]}
            </Button>
        }
        </ButtonGroup>
        {
          for deck, i in @state.decks
            <div className="ship-deck" className={if @state.activeDeck is i then 'show' else 'hidden'} key={i}>
              <PaneBody
                condStartTime={@condStartTime}
                key={i}
                deckIndex={i}
                deck={@state.decks[i]}
                activeDeck={@state.activeDeck}
                deckName={@state.names[i]}
              />
            </div>
        }
      </Panel>
